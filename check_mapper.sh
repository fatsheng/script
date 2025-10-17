#!/bin/bash

# 定义资源目录和Java源码目录
RESOURCES_DIR="resources/sqlmapper"
JAVA_DIR="java"

# 检查目录是否存在
if [ ! -d "$RESOURCES_DIR" ]; then
    echo "Error: Directory $RESOURCES_DIR does not exist."
    exit 1
fi

if [ ! -d "$JAVA_DIR" ]; then
    echo "Error: Directory $JAVA_DIR does not exist."
    exit 1
fi

# 创建一个数组来存储可删除的XML文件
declare -a removable_xml_files

# 遍历resources/sqlmapper目录下的所有XML文件
for xml_file in "$RESOURCES_DIR"/*.xml; do
    if [ -f "$xml_file" ]; then
        echo "Processing XML file: $xml_file"
        # 提取XML文件中的namespace属性值，即Mapper的类名
        class_name=$(grep -oP '(?<=<mapper namespace=")[^"]*' "$xml_file")
        
        if [ -z "$class_name" ]; then
            echo "Warning: No namespace found in $xml_file"
            continue
        fi
        
        echo "Found class name: $class_name"
        
        # 将包名和类名转换为文件路径
        class_path=$(echo "$class_name" | sed 's/\./\//g').java
        
        # 检查Java类文件是否存在
        if [ ! -f "$JAVA_DIR/$class_path" ]; then
            echo "Java class file $JAVA_DIR/$class_path does not exist."
            # 如果Java类文件不存在，将XML文件添加到可删除列表
            removable_xml_files+=("$xml_file")
            # 删除XML文件
            rm "$xml_file"
        else
            echo "Java class file $JAVA_DIR/$class_path exists."
        fi
    else
        echo "Warning: $xml_file is not a file."
    fi
done

# 输出所有可删除的XML文件
echo "以下XML文件可以删除："
for file in "${removable_xml_files[@]}"; do
    echo "$file"
done
