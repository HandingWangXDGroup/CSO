%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Implementation of a competitive swarm optimizer (CSO) for large scale optimization
%%
%%  See the details of CSO in the following paper
%%  R. Cheng and Y. Jin, A Competitive Swarm Optimizer for Large Scale Optmization,
%%  IEEE Transactions on Cybernetics, 45(2): 191-204, 2015
%%
%%  The test instances are the CEC'08 benchmark functions for large scale optimization
%%
%%  The source code CSO is implemented by Ran Cheng 
%%
%%  If you have any questions about the code, please contact: 
%%  Ran Cheng at r.cheng@surrey.ac.uk 
%%  Prof. Yaochu Jin at yaochu.jin@surrey.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

javaclasspath('CEC08 Func\FractalFunctions.jar');
addpath(genpath(pwd));

global initial_flag

%d: dimensionality
d = 1000;
%maxfe: maximal number of fitness evaluations
maxfe = d*5000;
%runnum: the number of trial runs
runnum = 1;

results = zeros(7,runnum);
 
for funcid = 1 : 7
    n = d;
    initial_flag = 0;
    
    switch funcid
         case 1

            % lu: define the upper and lower bounds of the variables
            lu = [-100 * ones(1, n); 100 * ones(1, n)];

        case 2

            lu = [-100 * ones(1, n); 100 * ones(1, n)];


        case 3

            lu = [-100 * ones(1, n); 100 * ones(1, n)];


        case 4

            lu = [-5 * ones(1, n); 5 * ones(1, n)];


        case 5

            lu = [-600* ones(1, n); 600 * ones(1, n)];



        case 6

            lu = [-32 * ones(1, n); 32 * ones(1, n)];


        case 7

            lu = [-1 * ones(1, n); 1 * ones(1, n)];


    end
    
    
    
    %phi setting (the only parameter in CSO, please SET PROPERLY)
    if(funcid == 1 || funcid == 4 || funcid == 5 || funcid == 6)
        %for seperable functions
        if(d >= 2000)
            phi = 0.2;
        elseif(d >= 1000)
            phi = 0.15;
        elseif(d >=500)
            phi = 0.1;
        else
            phi = 0;
        end;
    else
        if(d >= 2000)
            phi = 0.2;
        elseif(d >= 1000)
            phi = 0.1;
        elseif(d >=500)
            phi = 0.05;
        else
            phi = 0;
        end;
    end;
    
    % population size setting
    if(d >= 5000)
        m = 1500;
    elseif(d >= 2000)
        m = 1000;
    elseif(d >= 1000)
        m = 500;
    elseif(d >= 100)
        m = 100;
    end;


% several runs
for run = 1 : runnum



    % initialization
    XRRmin = repmat(lu(1, :), m, 1);
    XRRmax = repmat(lu(2, :), m, 1);
    rand('seed', sum(100 * clock));
    p = XRRmin + (XRRmax - XRRmin) .* rand(m, d);
    fitness = benchmark_func(p, funcid);
    v = zeros(m,d);
    bestever = 1e200;
    
    FES = m;
    gen = 0;
    

    tic;
    % main loop
    while(FES < maxfe)


        % generate random pairs
        rlist = randperm(m);
        rpairs = [rlist(1:ceil(m/2)); rlist(floor(m/2) + 1:m)]';
        
        % calculate the center position
        center = ones(ceil(m/2),1)*mean(p);
        
        % do pairwise competitions
        mask = (fitness(rpairs(:,1)) > fitness(rpairs(:,2)));
        losers = mask.*rpairs(:,1) + ~mask.*rpairs(:,2); 
        winners = ~mask.*rpairs(:,1) + mask.*rpairs(:,2);
   
        
        %random matrix 
        randco1 = rand(ceil(m/2), d);
        randco2 = rand(ceil(m/2), d);
        randco3 = rand(ceil(m/2), d);
        
        % losers learn from winners
        v(losers,:) = randco1.*v(losers,:) ...,
                    + randco2.*(p(winners,:) - p(losers,:)) ...,
                    + phi*randco3.*(center - p(losers,:));
        p(losers,:) = p(losers,:) + v(losers,:);
         
        % boundary control
        for i = 1:ceil(m/2)
            p(losers(i),:) = max(p(losers(i),:), lu(1,:));
            p(losers(i),:) = min(p(losers(i),:), lu(2,:));
        end

        
        % fitness evaluation
        fitness(losers,:) = benchmark_func(p(losers,:), funcid);
        bestever = min(bestever, min(fitness));
        FES = FES + ceil(m/2);
        fprintf('Best fitness: %e FES %d\n', bestever,FES); 
        
        
        gen = gen + 1;
    end;
    
    results(funcid, runnum) = bestever;
    fprintf('Run No.%d Done!\n', run); 
    disp(['CPU time: ',num2str(toc)]);
end;
 save results.mat results
end;


    

