FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python3.9 python3.9-dev python3.9-distutils

RUN  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 && \
    update-alternatives --set python3 /usr/bin/python3.9
# Update pip to correspond to the new Python version

COPY /Era3D /Era3d

WORKDIR /Era3d

RUN apt-get install -y wget

RUN mkdir sam_pt && cd sam_pt && \
    wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth && \
    cd .. 

RUN apt-get update && apt-get install -y git libgl1 libglib2.0-0 

RUN apt-get install -y build-essential

RUN pip install fire spaces 

RUN pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu118



RUN wget https://download.pytorch.org/whl/cu118/xformers-0.0.23.post1%2Bcu118-cp310-cp310-manylinux2014_x86_64.whl#sha256=dc5f828dbe187c1bf69d41853a55170d2506ff4c40fc0dfbea3bc7e18daed2e5
    
RUN pip install xformers-0.0.23.post1+cu118-cp310-cp310-manylinux2014_x86_64.whl

RUN git clone https://github.com/NVlabs/nvdiffrast /nvdiffrast && \
    cd /nvdiffrast && \
    pip install .

ENV TCNN_CUDA_ARCHITECTURES=86

ENV export CUDA_HOME=/usr/local/cuda-11.8

RUN pip install git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch
# RUN git clone https://github.com/NVlabs/tiny-cuda-nn.git /tiny && \
#     cd /tiny/bindings/torch && \
#     python setup.py install

RUN pip install -r requirements.txt

RUN python run_env.py

EXPOSE 7860

ENV GRADIO_SERVER_NAME="0.0.0.0"

CMD ["python", "app.py"]