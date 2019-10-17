% DBSCAN with OcTree
function [IDX, isnoise]=DBSCANOcTree(X,epsilon,MinPts)
    C=0;
    
    OT = OcTree3D(X,'binCapacity',20); 
    disp('Octree done')
    n=size(X,1);
    IDX=zeros(n,1);
    
    % D=pdist2(X,X);
    
    visited=false(n,1);
    isnoise=false(n,1);
    
    for i=1:n
        %sprintf('%0.1f %',i/n*100)
        if ~visited(i)
            visited(i)=true;
            
            Neighbors=OT.RegionQuery(i, epsilon);
            if numel(Neighbors)<MinPts
                % X(i,:) is NOISE
                isnoise(i)=true;
            else
                C=C+1;
                ExpandCluster(i,Neighbors,C);
            end
            
        end
    
    end
    
    function ExpandCluster(i,Neighbors,C)
        IDX(i)=C;
        
        k = 1;
        while true
            j = Neighbors(k);
            
            if ~visited(j)
                visited(j)=true;
                Neighbors2=OT.RegionQuery(j, epsilon);                
                if numel(Neighbors2)>=MinPts
                    Neighbors=[Neighbors Neighbors2];   %#ok
                end
            end
            if IDX(j)==0
                IDX(j)=C;
            end
            
            k = k + 1;
            if k > numel(Neighbors)
                break;
            end
        end
    end
    
    %{
    function Neighbors=RegionQuery(i)
    %    Neighbors=find(D(i,:)<=epsilon);
    end
    %}
end
