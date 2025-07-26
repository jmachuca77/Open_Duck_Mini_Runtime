#!/bin/bash
set -x
set -e

pushd /app/Open_Duck_Mini_Runtime/scripts
python v2_rl_walk_mujoco.py --onnx_model_path /root/checkpoints/BEST_WALK_ONNX_2.onnx -p 32 --cutoff_frequency 40
