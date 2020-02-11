#!/bin/bash
main()
{
    echo "FaceDetectionpythonapp prepareing"

    C31_flag=`find $HOME -maxdepth 1 -name "sample-facedetectionpython" 2> /dev/null`
    if [[ $C31_flag ]];then
        read -p "[INFO] The sample-facedetectionpython is existence.Do you want to re-prepare ? [Y/N]: " response
        if [ $response"z" = "Nz" ] || [ $response"z" = "nz" ]; then
            echo "Exit prepareing"
            return 1
        elif [ $response"z" = "Yz" ] || [ $response"z" = "yz" ] || [ $response"z" = "z" ]; then
            echo "[INFO] Please manually delete $HOME/sample-facedetectionpython director and re-execute this script"
            return 1
        else
            echo "[ERROR] Please input Y/N!"
            return 1
        fi
    fi
    
    sudo apt-get update
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Please check if the network is connected or Check if the sources in /etc/apt/sources.list are available"
        return 1
    fi

    mkdir $HOME/sample-facedetectionpython
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Execute mkdir command failed, Please check your environment"
        return 1
    fi  

    git --version
    if [[ $? -ne 0 ]];then
        echo "[INFO] git installation ... ..."
        sudo apt-get install git
        if [[ $? -ne 0 ]];then
            echo "[ERROR] Install git faild ,Please manually install"
            return 1
        fi
    fi

    git clone https://gitee.com/Atlas200DK/sample-facedetection-python.git $HOME/sample-facedetectionpython
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Clone faild, Please check your environment"
        return 1
    fi 
    
    grep "\<export DDK_HOME=\$HOME/tools/che/ddk/ddk\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export DDK_HOME=\$HOME/tools/che/ddk/ddk" >> $HOME/.bashrc
    fi
    grep "\<export LD_LIBRARY_PATH=\$DDK_HOME/uihost/lib\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export LD_LIBRARY_PATH=\$DDK_HOME/uihost/lib" >> $HOME/.bashrc
    fi
    source $HOME/.bashrc


    if [ ! -f "$HOME/sample-facedetectionpython/script/face_detection.om" ];then
        model_shape=`head -1 $HOME/sample-facedetectionpython/MyModel/shape_face_detection`
        download_url_caffemodel="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/face_detection/face_detection.caffemodel"
        download_url_prototxt="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/face_detection/face_detection.prototxt"
        download_url_license="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/face_detection/LICENSE"
        wget -O $HOME/sample-facedetectionpython/MyModel/face_detection.caffemodel ${download_url_caffemodel} --no-check-certificate
        wget -O $HOME/sample-facedetectionpython/MyModel/face_detection.prototxt ${download_url_prototxt} --no-check-certificate
        wget -O $HOME/sample-facedetectionpython/MyModel/LICENSE ${download_url_license} --no-check-certificate
        export SLOG_PRINT_TO_STDOUT=1 && export PATH=${PATH}:${DDK_HOME}/uihost/toolchains/ccec-linux/bin/ && export LD_LIBRARY_PATH=${DDK_HOME}/uihost/lib/ && export TVM_AICPU_LIBRARY_PATH=${DDK_HOME}/uihost/lib/:${DDK_HOME}/uihost/toolchains/ccec-linux/aicpu_lib && export TVM_AICPU_INCLUDE_PATH=${DDK_HOME}/include/inc/tensor_engine && export PYTHONPATH=${DDK_HOME}/site-packages && export TVM_AICPU_OS_SYSROOT=/usr/aarch64-linux-gnu && ${DDK_HOME}/uihost/bin/omg --output="$HOME/sample-facedetectionpython/script/face_detection" --check_report=$HOME/sample-facedetectionpython/MyModel/face_detection_result.json --plugin_path= --model="$HOME/sample-facedetectionpython/MyModel/face_detection.prototxt" --framework=0 --ddk_version=${tools_version} --weight="$HOME/sample-facedetectionpython/MyModel/face_detection.caffemodel" --input_shape=${model_shape} --insert_op_conf=$HOME/sample-facedetectionpython/MyModel/aipp_face_detection.cfg --op_name_map=$HOME/sample-facedetectionpython/MyModel/reassign_operators
        if [ $? -ne 0 ];then
            echo "ERROR: download failed, please check network connetction."
            return 1
        fi
    else
        echo "face_detection.om exists, skip downloading."
    fi
}
main
