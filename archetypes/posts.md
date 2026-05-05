+++
date = '{{ .Date }}'
draft = false
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
categories = ['课程笔记']
tags = []
+++

# {{ replace .File.ContentBaseName "-" " " | title }}

Write your post here.
