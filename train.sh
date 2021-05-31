#!/bin/sh

set -e
set -x

export PANGOLIN_WINDOW_URI=headless://

DATA_INPUT=examples/cups
DATA_OUTPUT=data_cups
SHAPE_DIR=~/ShapeNetCore.v2/

# create a home for the $DATA_OUTPUT
mkdir -p $DATA_OUTPUT

# pre-process the cups training set (SDF samples)
python3 preprocess_data.py --data_dir $DATA_OUTPUT --source $SHAPE_DIR --name ShapeNetV2 --split examples/splits/sv2_cups_train.json --skip

# train the model
python3 train_deep_sdf.py -e $DATA_INPUT  --batch_split 16

# pre-process the sofa test set (SDF samples)
python3 preprocess_data.py --data_dir $DATA_OUTPUT --source $SHAPE_DIR --name ShapeNetV2 --split examples/splits/sv2_cups_test.json --test --skip

# pre-process the sofa test set (surface samples)
python3 preprocess_data.py --data_dir $DATA_OUTPUT --source $SHAPE_DIR --name ShapeNetV2 --split examples/splits/sv2_cups_test.json --surface --skip

# reconstruct meshes from the sofa test split (after 100 epochs)
python3 reconstruct.py -e $DATA_INPUT -c 100 --split examples/splits/sv2_cups_test.json -d $DATA_OUTPUT --skip

# evaluate the reconstructions
python3 evaluate.py -e $DATA_INPUT -c 100 -d $DATA_OUTPUT -s examples/splits/sv2_cups_test.json 
