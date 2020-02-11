#!/bin/bash

script_path="$HOME/AscendProjects/sample-crowdcounting/script"
model_path="$HOME/AscendProjects/sample-crowdcounting/MyModel"

function download()
{
    model_name=$1
    License_OK=$2
    model_shape=`head -1 ${model_path}/shape_${model_name}`
    if [ ! -f "${script_path}/${model_name}.om" ];then
        download_url_license="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/${model_name}/LICENSE"
        if [[ ${License_OK} == "1" ]];then
            wget -O ${model_path}/LICENSEN_${model_name} ${download_url_license} --no-check-certificate
        fi

        download_url_pb="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/${model_name}/${model_name}.pb"
        wget -O ${model_path}/${model_name}.pb ${download_url_pb} --no-check-certificate

	export SLOG_PRINT_TO_STDOUT=1 && export PATH=${PATH}:${DDK_HOME}/uihost/toolchains/ccec-linux/bin/ && export LD_LIBRARY_PATH=${DDK_HOME}/uihost/lib/ && export TVM_AICPU_LIBRARY_PATH=${DDK_HOME}/uihost/lib/:${DDK_HOME}/uihost/toolchains/ccec-linux/aicpu_lib && export TVM_AICPU_INCLUDE_PATH=${DDK_HOME}/include/inc/tensor_engine && export PYTHONPATH=${DDK_HOME}/site-packages && export TVM_AICPU_OS_SYSROOT=/usr/aarch64-linux-gnu && ${DDK_HOME}/uihost/bin/omg --output="${script_path}/${model_name}" --check_report=${model_path}/${model_name}_result.json --plugin_path= --model="${model_path}/${model_name}.pb" --framework=3 --ddk_version=${tools_version} --input_shape=${model_shape} --insert_op_conf=${model_path}/aipp_${model_name}.cfg
	if [ $? -ne 0 ];then
            echo "ERROR: download failed, please check network connetction."
            return 1
        fi
    else
        echo "${script_path}/${model_name}.om exists, skip downloading."
    fi

    return 0
}

main()
{
    echo "Crowdcountingapp prepareing"

    AscendProjects_flag=`find $HOME -maxdepth 1 -name "AscendProjects" 2> /dev/null`
    if [[ ! $AscendProjects_flag ]];then
        mkdir $HOME/AscendProjects
        if [[ $? -ne 0 ]];then
            echo "[ERROR] Execute mkdir command failed, Please check your environment"
            return 1
        fi
    fi

    C31_flag=`find $HOME/AscendProjects -maxdepth 1 -name "sample-crowdcounting" 2> /dev/null`
    if [[ $C31_flag ]];then
        read -p "[INFO] The sample-crowdcounting is existence.Do you want to re-prepare ? [Y/N]: " response
        if [ $response"z" = "Nz" ] || [ $response"z" = "nz" ]; then
            echo "Exit prepareing"
            return 1
        elif [ $response"z" = "Yz" ] || [ $response"z" = "yz" ] || [ $response"z" = "z" ]; then
            echo "[INFO] Please manually delete $HOME/AscendProjects/sample-crowdcounting director and re-execute this script"
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

    mkdir $HOME/AscendProjects/sample-crowdcounting
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

    git clone https://gitee.com/Atlas200DK/sample-crowdcounting.git $HOME/AscendProjects/sample-crowdcounting --branch 1.3x.0.0
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Clone faild, Please check your environment"
        return 1
    fi 
    
    grep "\<export tools_version=1.31.T15.B150\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export tools_version=1.31.T15.B150" >> $HOME/.bashrc
    fi
    grep "\<export DDK_HOME=\$HOME/.mindstudio/huawei/ddk/1.31.T15.B150/ddk\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export DDK_HOME=\$HOME/.mindstudio/huawei/ddk/1.31.T15.B150/ddk" >> $HOME/.bashrc
    fi
    grep "\<export NPU_DEVICE_LIB=\$DDK_HOME/../RC/host-aarch64_Ubuntu16.04.3/lib\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export NPU_DEVICE_LIB=\$DDK_HOME/../RC/host-aarch64_Ubuntu16.04.3/lib" >> $HOME/.bashrc
    fi
    grep "\<export LD_LIBRARY_PATH=\$DDK_HOME/lib/x86_64-linux-gcc5.4\>" $HOME/.bashrc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "export LD_LIBRARY_PATH=\$DDK_HOME/lib/x86_64-linux-gcc5.4" >> $HOME/.bashrc
    fi
    source $HOME/.bashrc


    download "crowd_counting" "0"
}
main
