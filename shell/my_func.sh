#!/bin/bash
# 用source导入

# pipeline模式的删除空白行与所有#注释
del_anno_ppl() {
  grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' && return 0
  return 1
}

# 处理/n/r回车格式的文件为/n回车的文件，并留下原文件的bak版本，支持多文件处理
cvt_nr2n() {
  local TMP_FILE=ca18a09c-2850-4a1a-9bd3-ff19013619a0.txt
  for f in $@; do
    [[ -f $f ]] && (cat $f | sed 's/\r//g' > $TMP_FILE) && cp $f $f.bak && cat $TMP_FILE > $f && counitue
    echo "ERROR happens on handling the file $f" >&2
    [[ -f $TMP_FILE ]] && rm -f $TMP_FILE
    return 1
  done
  [[ -f $TMP_FILE ]] && rm -f $TMP_FILE
  return 0
}





