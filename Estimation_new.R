library(readxl)    # ��������ļ���ȡ
library(lubridate) # �������ʱ������
library(stringr)   # ��������ı�����
library(limSolve)  # ��������ⷽ����

bond <- read_xlsx('D://R/TermStructure/CN_bond_19-04-15.xlsx')
bond <- bond[!is.na(bond$ǰ���̼�),]
row.names(bond) <- 1:nrow(bond)
bond$��Ϣ�ն�[is.na(bond$��Ϣ�ն�)] <- bond$��Ϣ��һ[is.na(bond$��Ϣ�ն�)]

# ��һ�θ�Ϣ���ڴ���
pay_1st <- unlist(bond[,11])
pay_1st_month <- unlist(strsplit(str_extract(pay_1st, '(.|..)��'),'��'))
na_loc <- which(is.na(pay_1st_month))
pay_1st_month[na_loc] <- substr(pay_1st,5,6)[na_loc]
pay_1st_month <- as.numeric(pay_1st_month)

bond_in_1st <- pay_1st_month %in% c(4,7,10,1)
pay_1st_month <- pay_1st_month[bond_in_1st]
# �ڶ��θ�Ϣ���ڴ���
pay_2cd <- unlist(bond[,12])
pay_2cd_month <- unlist(strsplit(str_extract(pay_2cd, '(.|..)��'),'��'))
na_loc <- which(is.na(pay_2cd_month))
pay_2cd_month[na_loc] <- substr(pay_2cd,5,6)[na_loc]
pay_2cd_month <- as.numeric(pay_2cd_month)

bond_in_2cd <- pay_2cd_month %in% c(4,7,10,1)
pay_2cd_month <- pay_2cd_month[bond_in_2cd]


# ծȯɸѡ
bond_in <- bond_in_1st + bond_in_2cd
bond_fit <- bond[as.logical(bond_in),]

bond_fit <- bond_fit[1:74,]

# ��ȡծȯָ��
# ��������
n <- 5
nmax <- 4*n  # ��������*4 = ���Ƽ���
end_year <- year(bond_fit$��������)
end_year_real <- end_year
end_year[end_year > (2019+n)] <- 2019+n
end_month <- month(bond_fit$��������)

# Ʊ������
coupon <- bond_fit$Ʊ������


# �������亯��
fill_col <- function(lst){
  if(length(lst) < nmax){
    n_fill <- nmax - length(lst)
    lst <- c(lst, rep(0, n_fill))
  }
  else{
    lst <- lst[1:nmax]
  }
  return(lst)
}


# ��Ϣһ�κ͸�Ϣ���ε�ծȯ�ֿ�����
eql <- which(pay_1st_month==pay_2cd_month)

# Start here  
df_fit <- c()
log_add <- c()
log_file <- c()
for(i in 1:nrow(bond_fit)){
  # ֻ��Ϣһ��
  if(i %in% eql){
    if(end_month[i]==1){
      real_paytime <- c(c(0,0,1), rep(c(0,0,0,1),end_year[i]-2020))
      fill_paytime <- fill_col(real_paytime)
      df_fit <- c(df_fit, fill_paytime)
      log_file <- c(log_file, '��Ϣ1�Σ�1�µ���')
    }
    else if(end_month[i]==4){
      real_paytime <- c(c(0,0,0,1), rep(c(0,0,0,1),end_year[i]-2020))
      fill_paytime <- fill_col(real_paytime)
      df_fit <- c(df_fit, fill_paytime)
      log_file <- c(log_file, '��Ϣ1�Σ�4�µ���')
    }
    else if(end_month[i]==7){
      real_paytime <- c(1, rep(c(0,0,0,1),end_year[i]-2019))
      fill_paytime <- fill_col(real_paytime)
      df_fit <- c(df_fit, fill_paytime)
      log_file <- c(log_file, '��Ϣ1�Σ�7�µ���')
    }
    else if(end_month[i]==10){
      real_paytime <- c(c(0,1),rep(c(0,0,0,1),end_year[i]-2019))
      fill_paytime <- fill_col(real_paytime)
      df_fit <- c(df_fit, fill_paytime)
      log_file <- c(log_file, '��Ϣ1�Σ�10�µ���')
    }
  }
  # ��Ϣ����
  else{
    # ��2019��7��10�µ��ڵ�
    if(end_year[i] == 2019){
      if(end_month[i] == 7){
        real_paytime <- c(1,0,0,0)
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2019��7�µ���')
      }
      else if(end_month[i] == 10){
        real_paytime <- c(0,1,0,0)
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2019��10�µ���')
      }
    }
    else{
      if(end_month[i]==1){
        real_paytime <- c(c(1,0,1), rep(c(0,1,0,1),end_year[i]-2020))
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2020���Ժ�1�µ���')
      }
      else if(end_month[i]==4){
        real_paytime <- rep(c(0,1,0,1),end_year[i]-2019)
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2020���Ժ�4�µ���')
      }
      else if(end_month[i]==7){
        real_paytime <- c(1, rep(c(0,1,0,1),end_year[i]-2019))
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2020���Ժ�7�µ���')
      }
      else if(end_month[i]==10){
        real_paytime <- c(c(0,1),rep(c(0,1,0,1),end_year[i]-2019))
        fill_paytime <- fill_col(real_paytime)
        df_fit <- c(df_fit, fill_paytime)
        log_file <- c(log_file, '��Ϣ���Σ�2020���Ժ�10�µ���')
      }
    }
  }
  l <- length(df_fit)
  log_add <- c(log_add,l)
}

df_fit <- matrix(df_fit, nrow = nmax)
df_fit <- t(df_fit)


# ����ֽ���
# �ֽ�������
cashflow <- df_fit
# ��Ϣ�뵽���ֽ�����ֽ���
for(i in 1:nrow(cashflow)){
  if(end_year[i] == end_year_real[i]){
  cashflow[i,] <- cashflow[i,] * coupon[i]
  cashflow[i,max(which((cashflow[i,] == coupon[i])))] <- 100 + coupon[i]
  }
  else{
  cashflow[i,] <- cashflow[i,] * coupon[i]
  }
}


# �ع�
y <- bond_fit$ǰ���̼�
y <- y[20:length(y)]
X <- cashflow
X <- X[20:nrow(X),]
m1 <-lm(y~0+X)
r_lm <- 1/m1$coefficients - 1
plot(r_lm)

# ��Լ���ع�
A <- X
B <- y
N <- nmax
G_0 <- rbind(cbind(rep(0,N-1),-1*diag(N-1)),rep(0,N))
G_1 <- G_0 + diag(N)
G_2 <- diag(c(-1,rep(0,N-1)))
G <- rbind(G_2,G_1)
H <- c(-1,rep(0,N-1),rep(0, N))


reg <- lsei(A = A, B = B, G = G, H = H, type=2)
# ϵ��
reg
coe <- reg$X
r <- 1/coe-1
plot(r, type='l')

# �껯����
# �껯����
m <- seq(3,n*12,3)
ry <- r * 12/m
ts.plot(ry)
ry

