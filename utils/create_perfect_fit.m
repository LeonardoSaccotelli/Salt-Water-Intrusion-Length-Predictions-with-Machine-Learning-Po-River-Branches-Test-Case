function [] = create_perfect_fit(resumePredictions,algorithm_names,addBoundPerfectFit, percentageBoundPerfectFit, sharedTitle, isAllBranch)
%CREATE_PERFECT_FIT This function plot a perfect predictions plot
%   Input:
%   1) resumePredictions:
%   Table with a summary of observed and predicted values
%  
%   2) algorithm_names:
%   String array with the names of the trained models
%   
%   3) addBoundPerfectFit:
%   Boolean value to add or not a bound on the perfect predictions line
%
%   4) percentageBoundPerfectFit: 
%   Percentage bound to be added on the perfect predictions plot    
%
%   5)  sharedTitle: 
%   Common title of the plot
%
%   6) isAllBranch: 
%   Boolean value to indicate if the dataset contains all the Po Branches
%   or only one branch at time

    f = figure;
    f.Position = [0 0 1150 954];
    
    t = tiledlayout(2,2);
    for i = 1:numel(algorithm_names)
        nexttile;
        if isAllBranch
            plotAllBranch( ...
                resumePredictions(:,[1,2,i+2]), ...
                algorithm_names(i), ...
                addBoundPerfectFit, ...
                percentageBoundPerfectFit);
        else
            plotPerfectFit( ...
                resumePredictions(:,1), ...
                resumePredictions(:,i+1), ...
                algorithm_names(i), ...
                addBoundPerfectFit, ...
                percentageBoundPerfectFit);
        end
    end
    title(t,sharedTitle);
end

function plotPerfectFit(obs, pred, modelName, addBound, percentageBound)
    if (istable(obs))
        obs = table2array(obs);
    end
    
    if(istable(pred))
        pred = table2array(pred);
    end
    hAx=gca;                  
    legendName = {'Observations','Perfect prediction'};
    plot(obs,pred, '.','MarkerSize',20, ...
        'MarkerFaceColor',[0.00,0.00,0.1],'MarkerEdgeColor','auto');
    hold on;
    xy = linspace(0, 40, 40);
    plot(xy,xy,'k-','LineWidth',2);
    if(addBound)
        xyUpperBound = xy + percentageBound*xy/100;
        xyLowerBound = xy - percentageBound*xy/100;
        plot(xy,xyUpperBound, 'r--', 'LineWidth',2);
        plot(xy,xyLowerBound, 'r--', 'LineWidth',2);
        legendName = {"Observations","Perfect prediction", ...
            strcat(string(percentageBound), "% of deviation")};
    end
    hAx.LineWidth=1.4;
    xlim([0 40]);
    ylim([0 40]);
    xticks([0 5 10 15 20 25 30 35 40]);
    xticklabels({'0' '5' '10' '15' '20' '25' '30' '35' '40'});
    yticks([0 5 10 15 20 25 30 35 40]);
    yticklabels({'0' '5' '10' '15' '20' '25' '30' '35' '40'});
    xlabel('True response (km)');
    ylabel('Predicted response (km)');
    title(modelName);
    legend(legendName,'Location','northwest');
    set(gca,'FontSize',14);
    grid on;
    hold off;
end

function plotAllBranch(resumePredictions, modelName, addBound, percentageBound)
   
    goro = resumePredictions(resumePredictions.BranchName=="GORO",2:3);
    gnocca = resumePredictions(resumePredictions.BranchName=="GNOCCA",2:3);
    tolle = resumePredictions(resumePredictions.BranchName=="TOLLE",2:3);
    dritta = resumePredictions(resumePredictions.BranchName=="DRITTA",2:3);
    
    hAx=gca;                  
    legendName = {'Goro Observations','Gnocca Observations', ...
        'Tolle Observations','Dritta Observations', 'Perfect prediction'};

    plot( ...
        table2array(goro(:,1)), ...
        table2array(goro(:,2)), ...
        '.','MarkerSize',20, ...
        'MarkerFaceColor',[0.00,0.00,0.1],'MarkerEdgeColor','auto');

    hold on;
    plot( ...
        table2array(gnocca(:,1)), ...
        table2array(gnocca(:,2)), ...
        '.','MarkerSize',20, ...
        'MarkerFaceColor',[0.85,0.33,0.10],'MarkerEdgeColor','auto');

    plot( ...
        table2array(tolle(:,1)), ...
        table2array(tolle(:,2)), ...
        '.','MarkerSize',20, ...
        'MarkerFaceColor',[0.49,0.18,0.56],'MarkerEdgeColor','auto');
    
    plot( ...
        table2array(dritta(:,1)), ...
        table2array(dritta(:,2)), ...
        '.','MarkerSize',20, ...
        'MarkerFaceColor',[0.47,0.67,0.19],'MarkerEdgeColor','auto');
    
    xy = linspace(0, 40, 40);
    plot(xy,xy,'k-','LineWidth',2);
    if(addBound)
        xyUpperBound = xy + percentageBound*xy/100;
        xyLowerBound = xy - percentageBound*xy/100;
        plot(xy,xyUpperBound, 'r--', 'LineWidth',2);
        plot(xy,xyLowerBound, 'r--', 'LineWidth',2);
        legendName = {'Goro Observations','Gnocca Observations', ...
        'Tolle Observations','Dritta Observations', 'Perfect prediction', ...
            strcat(string(percentageBound), "% of deviation")};
    end
    hAx.LineWidth=1.4;
    xlim([0 40]);
    ylim([0 40]);
    xticks([0 5 10 15 20 25 30 35 40]);
    xticklabels({'0' '5' '10' '15' '20' '25' '30' '35' '40'});
    yticks([0 5 10 15 20 25 30 35 40]);
    yticklabels({'0' '5' '10' '15' '20' '25' '30' '35' '40'});
    xlabel('True response (km)');
    ylabel('Predicted response (km)');
    title(modelName);
    legend(legendName,'Location','northwest');
    set(gca,'FontSize',14);
    grid on;
    hold off;
end