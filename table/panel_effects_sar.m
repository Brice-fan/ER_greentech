function panel_effects_sar(results,vnames,W)
% PURPOSE: computes and prints direct, indirect and total effects estimates
%          for Elhorst SAR spatial panel models using the LeSage and Pace code
%---------------------------------------------------
% USAGE: panel_effects_sar(results,vnames,W)
% Where: results    = a structure returned by a spatial panel regression
%        vnames     = a structure of variable names
%        W          = spatial weights matrix used to estimate model
%---------------------------------------------------
%
% Effects estimates added by Donald J. Lacombe
% Donald J. Lacombe
% Research Associate Professor
% Regional Research Institute
% 886 Chestnut Ridge Road
% PO Box 6825
% Morgantown, WV 26506-6825
% donald.lacombe@mail.wvu.edu
% http://www.rri.wvu.edu/lacombe/~lacombe.htm
%
% REFERENCES:
% Elhorst JP (2010) Matlab Software for Spatial Panels. Under review.

% LeSage and Pace code for calcualting effects in a SAR model
% Adapted for the Elhorst spatial panel models
ndraw=1000;
uiter=50;
maxorderu=100;
nobs = results.N;
[junk nvar] = size(results.xwith);
rv=randn(nobs,uiter);
tracew=zeros(maxorderu,1);
wjjju=rv;
for jjj=1:maxorderu
    wjjju=W*wjjju;
    tracew(jjj)=mean(mean(rv.*wjjju));
    
end

traces=[tracew];
traces(1)=0;
traces(2)=sum(sum(W'.*W))/nobs;
trs=[1;traces];
ntrs=length(trs);
trbig=trs';

% cheat here to fix the numerical hessian
% Use MCMC to get good results
sigmat = results.hessi - diag(diag(results.hessi)) + diag(diag(abs(results.hessi)));
sigmatt = sigmat(1:end-1,1:end-1);
[R,posdef] = chol(sigmatt);

if posdef ~= 0 % even cheating did not work, so punt with a kludge
    tmp = [x W*y]'*[x W*y];
    sigmatt = sige*(inv(tmp));
end;

tmp = [results.beta
    results.rho];

bdraws = matadd(norm_rndmat(sigmatt,ndraw),tmp);
draws = bdraws';

psave = draws(:,end);
ind = find(psave > 1); % find bad rho draws
psave(ind,1) = 0.99;   % replace them with 0.99


bsave = draws(:,1:end-1);

if results.cflag == 1
    bdraws = bsave(:,2:end);
    nvar = nvar-1;
elseif results.cflag == 0
    bdraws = bsave;
end;
pdraws = psave;

ree = 0:1:ntrs-1;

rmat = zeros(1,ntrs);
total = zeros(ndraw,nvar,ntrs);
direct = zeros(ndraw,nvar,ntrs);
indirect = zeros(ndraw,nvar,ntrs);


for i=1:ndraw;
    rmat = pdraws(i,1).^ree;
    for j=1:nvar;
        beta = [bdraws(i,j)];
        total(i,j,:) = beta(1,1)*rmat;
        direct(i,j,:) = (beta*trbig).*rmat;
        indirect(i,j,:) = total(i,j,:) - direct(i,j,:);
    end;
    
end;

% Compute means, std deviation and upper and lower 0.95 intervals
p = nvar;
total_out = zeros(p,5);
total_save = zeros(ndraw,p);
for i=1:p;
    tmp = squeeze(total(:,i,:)); % an ndraw by 1 by ntraces matrix
    total_mean = mean(tmp);
    total_std = std(tmp);
    % Bayesian 0.95 credible intervals
    % for the cumulative total effects
    total_sum = (sum(tmp'))'; % an ndraw by 1 vector
    cum_mean = cumsum(mean(tmp));
    cum_std = cumsum(std(tmp));
    total_save(:,i) = total_sum;
    bounds = cr_interval(total_sum,0.95);
    cmean = mean(total_sum);
    smean = std(total_sum);
    ubounds = bounds(1,1);
    lbounds = bounds(1,2);
    total_out(i,:) = [cmean cmean./smean tdis_prb(cmean./smean,nobs) lbounds ubounds];
end;

% now do indirect effects
indirect_out = zeros(p,5);
indirect_save = zeros(ndraw,p);
for i=1:p;
    tmp = squeeze(indirect(:,i,:)); % an ndraw by 1 by ntraces matrix
    indirect_mean = mean(tmp);
    indirect_std = std(tmp);
    % Bayesian 0.95 credible intervals
    % for the cumulative indirect effects
    indirect_sum = (sum(tmp'))'; % an ndraw by 1 vector
    cum_mean = cumsum(mean(tmp));
    cum_std = cumsum(std(tmp));
    indirect_save(:,i) = indirect_sum;
    bounds = cr_interval(indirect_sum,0.95);
    cmean = mean(indirect_sum);
    smean = std(indirect_sum);
    ubounds = bounds(1,1);
    lbounds = bounds(1,2);
    indirect_out(i,:) = [cmean cmean./smean tdis_prb(cmean./smean,nobs) lbounds ubounds];
end;


% now do direct effects
direct_out = zeros(p,5);
direct_save = zeros(ndraw,p);
for i=1:p;
    tmp = squeeze(direct(:,i,:)); % an ndraw by 1 by ntraces matrix
    direct_mean = mean(tmp);
    direct_std = std(tmp);
    % Bayesian 0.95 credible intervals
    % for the cumulative direct effects
    direct_sum = (sum(tmp'))'; % an ndraw by 1 vector
    cum_mean = cumsum(mean(tmp));
    cum_std = cumsum(std(tmp));
    direct_save(:,i) = direct_sum;
    bounds = cr_interval(direct_sum,0.95);
    cmean = mean(direct_sum);
    smean = std(direct_sum);
    ubounds = bounds(1,1);
    lbounds = bounds(1,2);
    direct_out(i,:) = [cmean cmean./smean tdis_prb(cmean./smean,nobs) lbounds ubounds];
end;

% now print x-effects estimates

bstring = 'Coefficient';
tstring = 't-stat';
pstring = 't-prob';
lstring = 'lower 05';
ustring = 'upper 95';
cnames = strvcat(bstring,tstring,pstring,lstring,ustring);
ini.cnames = cnames;
ini.width = 2000;

% print effects estimates
if results.cflag == 1
    vnameso = strvcat(vnames(3:end,:));
elseif results.cflag == 0
    vnameso = strvcat(vnames(2:end,:));
end;


ini.rnames = strvcat('Direct  ',vnameso);
ini.fmt = '%16.6f';
ini.fid = 1;

% set up print out matrix
printout = direct_out;
mprint(printout,ini);

printout = indirect_out;
ini.rnames = strvcat('Indirect',vnameso);
mprint(printout,ini);

printout = total_out;
ini.rnames = strvcat('Total   ',vnameso);
mprint(printout,ini);
