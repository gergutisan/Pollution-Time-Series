function [ strLearningAlgorithm ] = learningAlgorithmNum2Str( numLearnAlg )

% LEARNING ALGORITHMS
            % (#1)'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                                
                                
            % (#2)'traingd'   - Gradient descent backpropagation.
            % (#3)'traingda'  - Gradient descent with adaptive lr backpropagation.
            % (#4)'traingdx'  - Variable Learning Rate Gradient Descent
            % (#5)'trainrp'   - RPROP Resilient Backpropagation.
            % (#6)'trainscg'  - Scaled conjugate gradient backpropagatio
            % (#7)'traingdm'  - Gradient Descent with Momentum

% Note for REGULARIZATION             
% net.trainFcn = 'trainbr' % Bayesian regularization
% trainbr is a network training function that updates the weight and bias values according 
% to Levenberg-Marquardt optimization. It minimizes a combination of squared errors and weights, 
% and then determines the correct combination so as to produce a network that generalizes well. 
% The process is called Bayesian regularization.

strLearnigAlgorithmCellArray = { 'trainlm'  ,...
                                 'traingd'  ,...
                                 'traingda' ,...
                                 'traingdx' ,...
                                 'trainrp'  ,...
                                 'trainscg' ,...
                                 'traingdm' ,...
                                 };          

strLearningAlgorithm = strLearnigAlgorithmCellArray{numLearnAlg};

end

