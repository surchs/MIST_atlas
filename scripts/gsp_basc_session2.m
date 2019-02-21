clear all;

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
%opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
%opt_g.min_xcorr_func = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.min_xcorr_anat = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.

% Build the files in list
root_p = '/mnt/data_sq/cisl/surchs/MIST_BASC';
files_in = load('../models/files_in_basc_gsp_session2.mat');
%%%%%%%%%%%%%%%%%%%%%
%% !! ALTERNATIVE METHOD
%% Grab the results of the region growing pipeline.
%% If the region growing pipeline has already been executed on this database, it is possible to start right out from its outputs.
%% To use this alternative method, uncomment the following line and suppress the block of code above ("Grabbing the results from the NIAK fMRI preprocessing pipeline")
%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%% Extra infos
%% These have to be organized in a comma-separated file (CSV). Example:
%%          , sex
%% subject1 , 0
%% subject2 , 1
%%
%% Note that the first entry has to be left empty. The subject IDs need to be identical to those used in the fMRI preprocessing pipeline.
%% Also, only numerical variables are supported (i.e. no 'M', 'W' to code for man and woman).
%% These variables will be used to split the subjects into strata, e.g. men vs women. In the group analysis, equal weight is given to all strata
%% (regardless of the number of subjects). Resampling of subjects is also made within strata, but not between them. Adding more covariates
%% will further stratify the group sample (e.g. two variables old/young men/women will translate into 4 strata).
%%
%% If you want to stratify the sample, uncomment the following line and indicate the csv file you want to use. Otherwise, just leave it as is.
%% To check that the file is properly formatted prior to running the pipeline, run the following command in Matlab/Octave:
%% [tab,labx,laby] = niak_read_csv('/data/infos.csv');
%% The subject IDs should load in LABX, the covariate IDs load in LABY, and the value of the variables into a numerical array TAB.
%%%%%%%%%%%%%%%%%%%%%


% files_in.infos = '/data/infos.csv'; % A file of comma-separeted values describing additional information on the subjects, this can be omitted

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.folder_out = [root_p filesep 'gsp_session2']; % Where to store the results
opt.region_growing.thre_size = 1000; %  the size of the regions, when they stop growing. A threshold of 1000 mm3 will give about 1000 regions on the grey matter.
opt.grid_scales = [10:10:100 120:20:200 240:40:500]'; % Search for stable clusters in the range 10 to 500
opt.scales_maps = [10     7     7;
                   10    12    12;
                   20    20    20;
                   40    36    36;
                   60    66    64;
                   120   120   122;
                   200   200   197;
                   320   320   325;
                   440   484   444];
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 500; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = true;   % Generate maps/time series at the individual level
opt.flag_mixed = true; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true;  % Generate maps/time series at the group level

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
opt.psom.max_queued = 30; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
pipeline = niak_pipeline_stability_rest(files_in,opt);
