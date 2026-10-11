#!/usr/bin/env python3
"""
YARG Song Converter & Decryptor
Decrypts YARG .yargsong package files (Crawford multi-value cipher) into Rock Band CON format.
Based on Nautilus specification and cipher logic.
"""

import sys
import os
import struct

HEADER_SIZE = 24
SET_LENGTH = 15
FILE_SIGNATURE = b"YARGSONG"

def decrypt_yargsong(src_path: str, dest_path: str) -> bool:
    if not os.path.isfile(src_path):
        print(f"Error: file not found: {src_path}")
        return False

    with open(src_path, "rb") as f_in:
        sig = f_in.read(8)
        if sig != FILE_SIGNATURE:
            print(f"Invalid signature: {sig} (expected {FILE_SIGNATURE})")
            return False

        z_byte = f_in.read(1)
        if not z_byte:
            return False
        z = z_byte[0] + 1679
        w = (z ^ 4) - z * 2
        n = 25 * w - 5
        x = (w + (z << 1)) ^ 4
        l = (n + 73) * (n + 23)
        l -= n * n + 96 * n
        x = -l + n + x - w * 25

        set_bytes = f_in.read(SET_LENGTH)
        if len(set_bytes) != SET_LENGTH:
            return False

        x = (x + 5) % 255
        values = [0, 0, 0, 0]
        for i in range(24):
            j = i * x
            values[0] = (values[0] + (set_bytes[j % 15] + i * 3298 + 88903)) & 0xFFFFFFFF
            values[1] = (values[1] - set_bytes[(j + 7001) % 15]) & 0xFFFFFFFF
            values[2] = (values[2] + set_bytes[j % 15]) & 0xFFFFFFFF
            values[3] = (values[3] + (j << 2)) & 0xFFFFFFFF

        a = values[0] & 0xFF
        b = values[1] & 0xFF
        c = values[2] & 0xFF

        os.makedirs(os.path.dirname(os.path.abspath(dest_path)), exist_ok=True)
        with open(dest_path, "wb") as f_out:
            total_read = 0
            chunk_size = 65536
            while True:
                chunk = f_in.read(chunk_size)
                if not chunk:
                    break
                out_chunk = bytearray(len(chunk))
                for i in range(len(chunk)):
                    pos = total_read + i
                    out_chunk[i] = ((chunk[i] - pos * c - b) & 0xFF) ^ a
                f_out.write(out_chunk)
                total_read += len(chunk)

    print(f"Decrypted {src_path} -> {dest_path} ({total_read} bytes)")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python yarg_converter.py <source.yargsong> [dest.con]")
        sys.exit(1)
    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else src.replace(".yargsong", ".con")
    success = decrypt_yargsong(src, dst)
    sys.exit(0 if success else 1)
