#!/usr/bin/env python3
from panflute import *

def flatten_meta(doc):
    doc.metadata['author'] = [author['name'] for author in doc.metadata['author']]

if __name__ == "__main__":
    toJSONFilter((lambda x, y: x), flatten_meta)
