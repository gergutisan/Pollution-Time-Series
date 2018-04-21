function [ strLearningAlgorithm ] = learningAlgorithmNum2Str( numLearnAlg )

% LEARNING ALGORITHMS
            % (#1)'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
            % (#2)'traingd'   - Gradient descent backpropagation.
            % (#3)'traingda'  - Gradient descent with adaptive lr backpropagation.
            % (#4)'traingdx'  - Variable Learning Rate Gradient Descent
            % (#5)'trainrp'   - RPROP Resilient Backpropagation.
            % (#6)   - Scaled conjugate gradient backpropagatio
            % (#7)'traingdm'  - Gradient Descent with Momentum

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

