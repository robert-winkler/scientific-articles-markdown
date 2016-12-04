#!/usr/bin/env python3
from panflute import *

def unflatten_meta(doc):
    # redefine vars with more complex structure
    institutes = []
    for index, name in zip(range(1,1000), doc.metadata['institute']):
        institute = dict()
        institute['index'] = index
        institute['name'] = name
        institutes.append(institute)

    affiliations = []
    authors = []
    for affil in doc.metadata['affiliation']:
        author = dict()
        authorIndex = int(affil['author'].text) - 1
        authorInstituteIndex = affil['institute']
        author['name'] = doc.metadata['author'][authorIndex]
        author['affiliation'] = authorInstituteIndex
        authors.append(author)

    doc.metadata['institute'] = institutes
    doc.metadata['author'] = authors

if __name__ == "__main__":
    toJSONFilter((lambda x, y: x), unflatten_meta)
