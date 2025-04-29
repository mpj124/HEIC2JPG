# -*- coding: utf-8 -*-
# @Time    : 2025/4/29
# @Author  : pengju
import os
import argparse
from PIL import Image
import pillow_heif
from pathlib import Path


def convert_heic_to_jpg(input_path, output_path, quality):
    try:
        heif_file = pillow_heif.open_heif(input_path)
        image = Image.frombytes(
            heif_file.mode,
            heif_file.size,
            heif_file.data,
            "raw",
            heif_file.mode,
            heif_file.stride,
        )
        output_path.parent.mkdir(parents=True, exist_ok=True)
        image.convert("RGB").save(output_path, "JPEG", quality=quality)
        print(f"✓ 转换成功: {input_path} -> {output_path}")
    except Exception as e:
        print(f"✗ 转换失败 [{input_path}]: {str(e)}")


def batch_convert(input_dir, output_dir, quality, recursive):
    pillow_heif.register_heif_opener()

    #绝对路径避免出错！
    input_path = Path(input_dir).resolve()
    output_root = Path(output_dir).resolve()

    #递归处理文件夹下的所有文件
    search_method = input_path.rglob if recursive else input_path.glob
    search_pattern = '**/*' if recursive else '*'

    for heic_file in search_method(search_pattern):
        if heic_file.suffix.lower() in ('.heic', '.heif'):
            relative_path = heic_file.relative_to(input_path)
            jpg_path = output_root / relative_path.with_suffix('.jpg')
            convert_heic_to_jpg(heic_file, jpg_path, quality)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="HEIC批量转换工具 - Windows版")
    parser.add_argument("input", help="输入目录路径")
    parser.add_argument("-o", "--output", default="converted", help="输出目录路径")
    parser.add_argument("-q", "--quality", type=int, default=85,
                        help="JPG质量 (1-100，默认85)")
    parser.add_argument("-r", "--recursive", action="store_true",
                        help="递归处理子目录")

    args = parser.parse_args()

    print("█ 开始转换...")
    batch_convert(
        args.input,
        args.output,
        args.quality,
        args.recursive
    )
    print("█ 所有文件处理完成！")
