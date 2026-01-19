from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ParserResult:
    text: str


class FileParser:
    extensions: frozenset[str] = frozenset()

    def parse(self, content_text: str | None, filename: str) -> ParserResult | None:
        raise NotImplementedError


class TextParser(FileParser):
    extensions = frozenset({"txt", "md", "csv"})

    def parse(self, content_text: str | None, filename: str) -> ParserResult:
        if content_text:
            return ParserResult(text=content_text)
        return ParserResult(text=f"Parsed text placeholder for {filename}.")


class DocxParser(FileParser):
    extensions = frozenset({"docx"})

    def parse(self, content_text: str | None, filename: str) -> ParserResult:
        if content_text:
            return ParserResult(text=content_text)
        return ParserResult(text=f"Parsed DOCX placeholder for {filename}.")


class PdfParser(FileParser):
    extensions = frozenset({"pdf"})

    def parse(self, content_text: str | None, filename: str) -> ParserResult:
        if content_text:
            return ParserResult(text=content_text)
        return ParserResult(text=f"Parsed PDF placeholder for {filename}.")


_PARSERS: list[FileParser] = [TextParser(), DocxParser(), PdfParser()]


def parse_content(extension: str, content_text: str | None, filename: str) -> ParserResult | None:
    for parser in _PARSERS:
        if extension in parser.extensions:
            return parser.parse(content_text, filename)
    return None
