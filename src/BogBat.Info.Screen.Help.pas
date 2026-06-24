{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Info.Screen.Help;

interface

uses
  BogBat.Info.Screen.Base;

type

  THelpScreen = class sealed(TInfoScreen)
    strict private
      const
        HelpText =
        '''
        BogBat is a simple template replacement program that creates an output
        text file by replacing placeholders in one file with data values read
        from another file.

        Normal usage:

          bogbat -d:data_file [-t:template_file] [-o:output_file] [options]

        Parameters:

          data_file

            Name of the file containing the data to be used to for placeholder
            replacement. Required. File format expected to be UTF-8, but this
            can be changed using the --data-encoding option (see below).

          template_file

            Name of the file containing the placeholders to be replaced.
            Optional. If not specified then the template is read from standard
            input. File format expected to be UTF-8, but this can be changed
            using the --template-encoding option (see below).

          output_file

            Name of the output file. Optional. If not specified then output is
            written to standard output. By default the file is written in UTF-8
            format, but this can be changed using the --output-encoding option
            (see below).

        Options:

          Zero or more of the following options can be specified:

          --data-encoding=encoding_id

            Specifies the text encoding of data_file. If data_file has a
            preamble / BOM then that is used to determine the encoding and
            --data-encoding is ignored.

          --template-encoding=encoding_id

            Specifies the text encoding of template_file. If template_file has a
            preamble / BOM then that is used to determine the encoding and
            --template-encoding is ignored.

          --output-encoding=encoding_id

            Specifies the text encoding to be used when writing output_file.

          --encoding=encoding_id

            Same as specifying --data-encoding, --template-encoding and
            --output-encoding all with the same encoding_id. If either data_file
            or template_file have a preamble / BOM then that is used to
            determine those files' encoding, regardless of the value specified
            by --encoding.

          In the above options encoding_id must be one of the following:

            | encoding_id | Description                                        |
            |-------------|----------------------------------------------------|
            | +ve number  | the encoding's code page as a positive decimal     |
            |             | number, eg 1252.                                   |
            | ascii       | ASCII format.                                      |
            | utf-8       | UTF-8 format (the default).                        |
            | utf-16-le   | UTF-16 little endian format.                       |
            | utf-16-be   | UTF-16 big endian format.                          |
            | utf-16      | alias for utf-16-le.                               |
            | acp         | operating system default ANSI code page.           |
            | os-default  | alias for acp.                                     |
            | 0           | alias for acp.                                     |
            |-------------|----------------------------------------------------|

            Hyphenated encoding_id values can optionally be written without any
            hyphens, e.g. utf16le is equivalent to utf-16-le, but utf-16le is
            not valid. Case is not significant for encoding_id values.

          --output-preamble

            Indicates that an encoding preamble / BOM should be written to
            output_file. Ignored if the output file encoding does not use a
            preamble / BOM.

          --delimiters=delims

            Specifies the delimiters to be used to begin and end a replacable
            template. Delimiters must comprise one or more punctuation or symbol
            characters. Opening delimiters must be different to closing
            delimiters.

            For commonly used delimiters delims may be one of the following
            predefined names:

            | delimiter name | opening delimiter | closing delimiter |
            |----------------|-------------------|-------------------|
            | moustache      | {{                | }}                |
            | mustache       | {{ (default)      | }} (default)      |
            | django         | {%                | %}                |
            | asp            | <%                | %>                |
            | php            | <?                | ?>                |
            | php2           | <?                | ?>                |
            | html           | <!--              | -->               |
            | perl           | <?                | !>                |
            | smarty         | {$                | }                 |
            |----------------|-------------------|-------------------|

            Case is not significant for the above names.

            Any other delimiters must be specified explicitly, as follows: the
            opening delimiter followed by a separator followed by a closing
            delimiter. The separator must be one or more alphanumeric characters
            or spaces.

            If any of the delimiter characters have a special purpose on the
            command line, or if spaces are used as delimiters, then the value
            must be quoted.

            Example delimiter definition values are "<a>", [999], "{{{ }" and
            {Y}.

        Other usages:

          bogbat

            Displays brief usage information and then exits.

          bogbat -V

            Displays the program's version information and then exits.

          bogbat -?

            Displays this help information and then exits.

        Aliases:

          The following short and long form commands are equivalent:

          | Short form       | Long form                |
          |------------------|--------------------------|
          | -d:data_file     | --data=data_file         |
          | -t:template_file | --template=template_file |
          | -o:output_file   | --output=output_file     |
          | -l:delims        | --delimiters=delims      |
          | -V               | --version                |
          | -?               | --help                   |
          |------------------|--------------------------|

          The colon used to separate a short form option from its value is
          optional. Alternatively the colon may be replaced by an equal sign.
          For example -d:data_file, -d=data_file and -ddata_file are all
          equivalent.

          Short form commands may begin with a forward slash instead of a
          hyphen, e.g. /V and /d:data_file.
        ''';
  public
    procedure Display; override;
  end;

implementation

{ THelpScreen }

procedure THelpScreen.Display;
begin
  Logger.WriteLn(HelpText);
end;

end.

