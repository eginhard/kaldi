#!/bin/bash

# Copyright 2016 Pegah Ghahremani

# This scripts extracts iVector using global iVector extractor
# trained on all languages in multilingual setup.

. ./cmd.sh
set -e
stage=1
train_set=train_sp_hires # train_set used to extract ivector using shared ivector
                         # extractor.
ivector_suffix=_gb
nnet3_affix=

. ./utils/parse_options.sh

lang=$1
global_extractor=$2

if [ $stage -le 7 ]; then
  # We extract iVectors on all the train_nodup data, which will be what we
  # train the system on.
  # Having a larger number of speakers is helpful for generalization, and to
  # handle per-utterance decoding well (iVector starts at zero) => hence max2
  steps/online/nnet2/copy_data_dir.sh --utts-per-spk-max 2 data/$lang/${train_set} data/$lang/${train_set}_max2
  ivec_dir=exp/$lang/nnet3${nnet3_affix}/ivectors_${train_set}${ivector_suffix}
  [ -d $ivec_dir ] && rm -rd $ivec_dir
  mkdir -p $ivec_dir
  steps/online/nnet2/extract_ivectors_online.sh \
      --cmd "$train_cmd" --nj 200 \
      data/$lang/${train_set}_max2 $global_extractor $ivec_dir || exit 1;
fi
exit 0;
