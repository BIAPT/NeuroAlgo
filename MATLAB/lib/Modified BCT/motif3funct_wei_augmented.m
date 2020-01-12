function [intensity,coherence,frequency, source, target, distance] = motif3funct_wei_augmented(W, channels_location)
%MOTIF3FUNCT_WEI       Intensity and coherence of functional class-3 motifs
%   Suppose to output also the source, target and distance
%   [intensity, coherence, frequency] = motif3funct_wei_augmented(W);
%
%   *Structural motifs* are patterns of local connectivity in complex
%   networks. In contrast, *functional motifs* are all possible subsets of
%   patterns of local connectivity embedded within structural motifs. Such
%   patterns are particularly diverse in directed networks. The motif
%   frequency of occurrence around an individual node is known as the motif
%   fingerprint of that node. The motif intensity and coherence are
%   weighted generalizations of the motif frequency. The motifp
%   intensity is equivalent to the geometric mean of weights of links
%   comprising each motif. The motif coherence is equivalent to the ratio
%   of geometric and arithmetic means of weights of links comprising each
%   motif.  
%
%   Input:      W,      weighted directed connection matrix
%                       (all weights must be between 0 and 1)
%
%   Output:     intensity,      node motif intensity fingerprint
%               coherence,      node motif coherence fingerprint
%               frequency,      node motif frequency fingerprint
%               
%               source,        num_motifs, channel
%               target,        num_motifs, channel
%               distance,      num_motifs, channel
    
%
%   Notes: 
%       1. The function find_motif34.m outputs the motif legend.
%       2. Average intensity and coherence are given by I./F and Q./F
%       3. All weights must be between 0 and 1. This may be achieved using
%          the weight_conversion.m function, as follows: 
%          W_nrm = weight_conversion(W, 'normalize');
%   	4. There is a source of possible confusion in motif terminology.
%          Motifs ("structural" and "functional") are most frequently
%          considered only in the context of anatomical brain networks
%          (Sporns and K�tter, 2004). On the other hand, motifs are not
%          commonly studied in undirected networks, due to the paucity of
%          local undirected connectivity patterns.
%
%   References: Onnela et al. (2005), Phys Rev E 71:065103
%               Milo et al. (2002) Science 298:824-827
%               Sporns O, K�tter R (2004) PLoS Biol 2: e369
%
%
%   Mika Rubinov, UNSW/U Cambridge, 2007-2015
%   Modification History:
%   2007: Original
%   2015: Improved documentation

persistent M3 ID3 N3
if isempty(N3)
    load motif34lib M3 ID3 N3             	%load motif data
end

n=length(W);                                %number of vertices in W
intensity=zeros(13,n);                              %intensity
coherence=zeros(13,n);                              %coherence
frequency=zeros(13,n);                          	%frequency

% The first 2 matrices are used to know which channel is a source and
% which one is a target for each motif
% the distance is used to know if its short range connection they are
% making or long range connection
source = zeros(13, n);
target = zeros(13, n);
distance = zeros(13, n);

A=1*(W~=0);                                 %adjacency matrix
As=A|A.';                                   %symmetrized adjacency

for u=1:n-2                               	%loop u 1:n-2
    V1=[false(1,u) As(u,u+1:n)];         	%v1: neibs of u (>u)
    for v1=find(V1)
        V2=[false(1,u) As(v1,u+1:n)];       %v2: all neibs of v1 (>u)
        V2(V1)=0;                           %not already in V1
        V2=([false(1,v1) As(u,v1+1:n)])|V2; %and all neibs of u (>v1)
        for v2=find(V2)
            w=[W(v1,u) W(v2,u) W(u,v1) W(v2,v1) W(u,v2) W(v1,v2)];
            a=[A(v1,u);A(v2,u);A(u,v1);A(v2,v1);A(u,v2);A(v1,v2)];
            ind=(M3*a)==N3;                 %find all contained isomorphs
            m=sum(ind);                     %number of isomorphs

            M=M3(ind,:).*repmat(w,m,1);
            id=ID3(ind);
            l=N3(ind);

            x=sum(M,2)./l;                  %arithmetic mean
            M(M==0)=1;                      %enable geometric mean
            i=prod(M,2).^(1./l);            %intensity
            q=i./x;                         %coherence

            [idu,j]=unique(id);             %unique motif occurences
            j=[0;j];                        %#ok<AGROW>
            mu=length(idu);                 %number of unique motifs
            i2=zeros(mu,1);
            q2=i2; 
            f2=i2;

            % Calculate the distance between all
            %[A(v1,u);A(v2,u);A(u,v1);A(v2,v1);A(u,v2);A(v1,v2)];
            loc_v1 = [channels_location(v1).X channels_location(v1).Y channels_location(v1).Z];
            loc_u = [channels_location(u).X channels_location(u).Y channels_location(u).Z];
            loc_v2 = [channels_location(v2).X channels_location(v2).Y channels_location(v2).Z];
            
            d_v1_u = channels_distance(loc_v1, loc_u);
            d_v2_u = channels_distance(loc_v2, loc_u);
            d_u_v1 = d_v1_u;
            d_v2_v1 = channels_distance(loc_v2, loc_v1);
            d_u_v2 = d_v2_u;
            d_v1_v2 = d_v2_v1;
            
            distances = [d_v1_u; d_v2_u; d_u_v1; d_v2_v1; d_u_v2; d_v1_v2].*a; % this will set to 0 those that are not connected
            

            
            % Here we increment the source and target for motif 7
            if(ismember(7,idu))
               source(7, [u v1 v2]) = source(7, [u v1 v2]) + [1 1 1]; % every channel is a source            
               target(7, [u v1 v2]) = target(7, [u v1 v2]) + [1 1 1]; % every channel is also a target
            
               distance(7, u) = distance(7, u) + distances(1) + distances(2) + distances(3) + distances(5);
               distance(7, v1) = distance(7, v1) + distances(1) + distances(3) + distances(4) + distances(6);
               distance(7, v2) = distance(7, v2) + distances(2) + distances(4) + distances(5) + distances(6);
            end
            
            if(ismember(1,idu))
                % then its the node u that gets a +2 in target
                % and the other two that get a +1 in source
                if(a(1) && a(2))
                    source_score = [0 1 1];
                    target_score = [2 0 0];
                % Then its node v1 that get a +2 in target
                elseif(a(3) && a(4)) 
                    source_score = [1 0 1];
                    target_score = [0 2 0];
                % othewise its v2
                else
                    source_score = [1 1 0];
                    target_score = [0 0 2];
                end
                
                source(1, [u v1 v2]) = source(1, [u v1 v2]) + source_score;
                target(1, [u v1 v2]) = target(1, [u v1 v2]) + target_score;
                
                distance(1, u) = distance(1, u) + distances(1) + distances(2) + distances(3) + distances(5);
                distance(1, v1) = distance(1, v1) + distances(1) + distances(3) + distances(4) + distances(6);
                distance(1, v2) = distance(1, v2) + distances(2) + distances(4) + distances(5) + distances(6);
            end
            
            for h=1:mu                      %for each unique motif
                i2(h)=sum(i(j(h)+1:j(h+1)));    %sum all intensities,
                q2(h)=sum(q(j(h)+1:j(h+1)));    %coherences
                f2(h)=j(h+1)-j(h);              %and frequencies
            end

            %then add to cumulative count
            intensity(idu,[u v1 v2])=intensity(idu,[u v1 v2])+[i2 i2 i2];
            coherence(idu,[u v1 v2])=coherence(idu,[u v1 v2])+[q2 q2 q2];
            frequency(idu,[u v1 v2])=frequency(idu,[u v1 v2])+[f2 f2 f2];
        end
    end
end