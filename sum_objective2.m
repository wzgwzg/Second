function y=sum_objective2(t)
load('d2objects.mat','objects');
N=objects(end,1);
tmpobjects=objects;
t=round(t);
omega=800;
sigma=10;

for i=1:N
    m=find(objects(:,1)==i);
    si=size(m,1);%��i��object�����֡��
    for j=i+1:N
        g=[];
        r=[];
        gg=[];
        rr=[];
   
        n=find(objects(:,1)==j);
        sj=size(n,1);%��j��object�����֡��
       
        is=objects(m(1),2); %����i��һ�γ��ֵ�֡
        js=objects(n(1),2); %����j��һ�γ��ֵ�֡
        sm=t(i):(t(i)+si-1);
        sn=t(j):(t(j)+sj-1);
        
        if ~isempty(m) && ~isempty(n)
            v0=intersect(objects(m,2),objects(n,2));%object i,j��ԭ��Ƶ��ͬʱ���ֵ�֡
            tmpobjects(m(1):m(end),2)=sm;
            tmpobjects(n(1):n(end),2)=sn;
            v=intersect(tmpobjects(m,2),tmpobjects(n,2));%object i,j��Ũ����Ƶ��ͬʱ���ֵ�֡
        end
        
        if ~isempty(v0)
            for p=1:length(v0)
                r(p)=find(objects(:,1)==i&objects(:,2)==v0(p));
                g(p)=find(objects(:,1)==j&objects(:,2)==v0(p));
            end
            
            d_Euclidean=min(sum( (objects(r,7:8)-objects(g,7:8)).^2, 2));%%%%%%%%��i,��j��Ŀ��֮�����Сŷʽ����
            E_t(i,j)=exp(-d_Euclidean/omega)*exp(abs((t(j)-t(i))-(js-is)));
        elseif (t(j)-t(i))*(js-is)>0
            E_t(i,j)=0;
        else
            E_t(i,j)=exp(abs(t(i)-t(j))/sigma);
        end
        
        
        %         if ((t(j)-t(i))*(n(1)-m(1))>0)
        %             E_t(i,j)=0;
        %         else
        %             %%ָ����ò��üӸ��ţ�
        %             E_t(i,j)=exp(abs(sn(1)-sm(1))/sigma_space);
        %         end
        
        for pp=1:length(v)
            rr(pp)=find(tmpobjects(:,1)==i&tmpobjects(:,2)==v(pp));
            gg(pp)=find(tmpobjects(:,1)==j&tmpobjects(:,2)==v(pp));
        end
        
        boxx=tmpobjects(rr,3:6);
        boxy=tmpobjects(gg,3:6);
        E_c(i,j)=sum(diag(rectint(boxx,boxy)));
        
    end
    
end

gama=0;
alpha=1;

%%%%%%%%%%%%%%%%%%%%%%
%disp(['time consistency',num2str(gama*sum(sum(E_t)))]);
%disp(['collision',num2str(alpha*sum(sum(E_c)))]);
%%%%%%%%%%%%%%%%%%%%%%%%

%y=( sum(E_alpha+lambda1*E_s) + sum(sum((lambda2*E_t+lambda3*E_c))) );
y=sum(sum((gama*E_t+alpha*E_c)));

