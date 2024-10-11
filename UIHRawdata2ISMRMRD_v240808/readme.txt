所附为可将联影的Rawdata转换为ISMRMRD数据格式的工具，具体使用方法可参考指令-h提示：
uih rawdata converter:
  -h [ --help ]                         help info
  -f [ --rawfile ] arg                  single rawdata file
  -g [ --dataset-groupname ] arg (=dataset)
                                        dataset group name
  -x [ --parameter-stylesheet-file ] arg
                                        parameter style sheet file
  -o [ --output ] arg                   output filename

common usage:
        uih-raw-2-ismrmrd.exe -f <UIH-RAWDATA-FILE-PATH> -x <CONVERT-FILE-PATH> -o <OUTPUT-PATH>

example:
        uih-raw-2-ismrmrd.exe -f C:\gre__2d.raw -x C:\prot_convert_default.xslt -o C:\output\testdata.h5

数据转换所需的协议文件(parameter style sheet file)也已包含在附件中，例如对于常用Cartesian采集模式的kspace，可直接通过调用prot_convert_default.xslt文件完成数据格式转换。