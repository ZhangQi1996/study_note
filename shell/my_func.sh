#!/bin/bash
# 用source导入

# pipeline模式的删除空白行与所有#注释
del_anno_ppl() {
  grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' && return 0
  return 1
}





