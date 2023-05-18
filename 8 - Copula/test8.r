install.packages('Matrix')
install.packages('copula')
library('copula')

data <- readRDS('./Copula_Test/var_10.rds')
names(data)
data
head(data)


plot(data$predictor,data$output,main = 'predictor vs output', col = 'green',pch = 20,xlab = 'predictor', ylab = 'output')


pred_out <- cbind(data$predictor,data$output)
e_cop <-pobs(pred_out)
plot(e_cop[,1],e_cop[,2],pch = 21,main ="pobs(Predictor vs Outpur) ",col = "blue")

#Normal copula
normal_copula<-normalCopula(param=0.9,dim=2)
#Student copula
t_copula <-ellipCopula(family = "t",param = 1,dim = 2)
#Frank copula
Frank_copula<-frankCopula(param=6,dim=2)
#previous 2, 6
#Clayton
Clayton_copula<-claytonCopula(param=7,dim=2)

#gaussian
my_hist3d <- function(x, y, freq, nclass="auto") {
  n<-length(x)
  if (nclass == "auto") { nclass<-ceiling(sqrt(nclass.Sturges(x))) }
  breaks.x <- seq(min(x),max(x),length=(nclass+1))
  breaks.y <- seq(min(y),max(y),length=(nclass+1))
  h <- NULL
  for (i in 1:nclass) 
    for (j in 1:nclass) 
      h <- c(h, sum(x <= breaks.x[j+1] & x >= breaks.x[j] & y <= breaks.y[i+1] & y >= breaks.y[i] ) )
  dim(h) <- c(nclass,nclass) 
  return (list(breaks.x = breaks.x[-1],breaks.y= breaks.y[-1],h = h))
}
my_hist <- my_hist3d(e_cop[,1],e_cop[,2], freq=FALSE,nclass = 10)


persp(my_hist$breaks.x,my_hist$breaks.y,my_hist$h,theta = 10)
Gaussian.Copula.Object<-normalCopula(param=0.9,dim=2)
Gaussian.Copula.fit<-fitCopula(Gaussian.Copula.Object, 
                               e_cop, 
                               method = "ml",
                               optim.control = list(maxit=1000))
parameters <- Gaussian.Copula.fit@copula@parameters
parameters



#student
student.cop <- ellipCopula(family = "t",param = 1,dim = 2)
t.Copula.fit<-fitCopula(student.cop, 
                        e_cop, 
                        method = "ml",
                        optim.control = list(maxit=1000))
parameters <- t.Copula.fit@copula@parameters
parameters



#frank
Frank.Copula.fit<-fitCopula(Frank_copula, 
                            e_cop, 
                            method = "ml",
                            optim.control = list(maxit=1000))
parameters <- Frank.Copula.fit@copula@parameters
parameters


#clayton
Clayton.Copula.fit<-fitCopula(Clayton_copula, 
                              e_cop, 
                              method = "ml",
                              optim.control = list(maxit=1000))
parameters <- Clayton.Copula.fit@copula@parameters
parameters

t.Copula.fit@loglik

Gaussian.Copula.fit@loglik

Frank.Copula.fit@loglik

Clayton.Copula.fit@loglik

#choosing frank copula

best_parameters <- parameters
persp(Clayton_copula, dCopula, main="pdf",xlab="u", ylab="v", zlab="c(u,v)") 
contour(Clayton_copula,dCopula, main="pdf",xlab="u", ylab="v")

predictor.copula <- pnorm(data$predictor,mean =  data$predictor_DistrParameters[1],sd=data$predictor_DistrParameters[2])
output.copula <- pexp(data$output,rate = data$output_DistrParameters[2])

plot(predictor.copula,output.copula,main = 'predictor vs output. Marginal Distribution Copula', col = 'green',pch = 20,xlab = 'predictor', ylab = 'output')

quantileLevel <- function(numCopula,copula, theta,alpha)
{
  if (numCopula == 1)
  {
    #Gaussian    
    q <- pnorm(qnorm(alpha) *sqrt(1-theta*theta)  + theta* qnorm(copula[,1]))
  }
  if (numCopula == 2)
  {
    
    #Student
  }
  if (numCopula == 3)
  {
    #Frank
    q <- (-1/theta)*log(1 - alpha*(1 - exp(-theta))/(exp(-theta*copula[,1]) + alpha*(1 - exp(-theta*copula[,1]))))
  }
  if (numCopula == 4)
  {
    #Clayton
  }
  return(q)  
}
copula <- cbind(predictor.copula,output.copula)
alpha <- 0.95
copulanum <- 3
parameters <- Frank.Copula.fit@copula@parameters
quantile <- quantileLevel(copulanum,copula, parameters,alpha)

(anomalindex <- which(copula[,2]>quantile))

plot(copula[,1],copula[,2],pch =20,col = "blue",main = "quatile level 95%")
points(copula[,1],quantile,col = "green",pch = 20)
points(copula[anomalindex,1],copula[anomalindex,2],col = "magenta",pch = 20)

anomal_predictor <- data$predictor[anomalindex]
anomal_output    <- data$output[anomalindex]
head(anomal_predictor)

plot(pred_out[,1],pred_out[,2],pch = 21,col= "blue",main ="Ruble vs Brent.Rates.Anomalies")
points(pred_out[anomalindex,1],pred_out[anomalindex,2],pch = 21,col= "magenta")


variant <- 10
copulaNames <- c("normal", "student", "clayton","frank")
copulaName <-copulaNames[3]
copulaName

myResult <- list(variant = variant,
                 copulaName = copulaName,
                 predictor.copula = predictor.copula,
                 output.copula = output.copula,  
                 best_parameters = best_parameters,
                 anomal_predictor= anomal_predictor,
                 anomal_output= anomal_output)

myResult

saveRDS(myResult,"result.rds")












