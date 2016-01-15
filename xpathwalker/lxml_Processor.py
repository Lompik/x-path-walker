from xpathwalker.processor import Processor
import os
import sys
import lxml.etree
import lxml.html


class lxmlProcessor(Processor):
    """ [X/HT]ML processor
    """
    def list_paths(self, with_attrs=False):
        if(not self.parsed):
            raise ValueError("No data in parsed")
        parsed = self.parsed
        res = []
        for el in parsed.xpath("//*"):
            if(with_attrs):
                if el.keys() is None:
                    res.append("/%s | %s | %s" % (parsed.getelementpath(el), ",".join(el.keys())))
                else:
                    res.append("/%s | %s" % (parsed.getelementpath(el), ",".join(["%s: %s" % (attr, el.get(key=attr)) for attr in el.keys()])))
            else:
                res.append("/%s" % (parsed.getelementpath(el)))
        return(res)

    def get_path_line_number(self, xpath, with_attrs=False):
        if(not self.parsed):
            raise ValueError("No data in parsed")
        parsed = self.parsed
        xpath = xpath.split(" | ")[0] if (with_attrs is True) else xpath
        res = 0
        if(len(parsed.xpath(xpath)) > 0):
            res = parsed.xpath(xpath)[0].sourceline
        return(res)

class HTML_Processor(lxmlProcessor):
    def parse_file(self, file):
        """HTML file parse from lxml

        :param file: file path (string)
        :returns: null
        :rtype:

        """
        self.parsed = lxml.html.parse(file)

class XML_Processor(lxmlProcessor):
    def parse_file(self, file):
        """HTML file parse from lxml

        :param file: file path (string)
        :returns: null
        :rtype:

        """
        self.parsed = lxml.etree.parse(file)
