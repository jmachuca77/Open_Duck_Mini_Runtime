#!/bin/bash
set -x
set -e

pushd /home/jaime/Open_Duck_Mini_Runtime/scripts
python v2_rl_walk_mujoco.py --onnx_model_path /home/jaime/Open_Duck_Mini_Runtime/checkpoints/BEST_WALK_ONNX_2.onnx
