local messages = {}

messages.help_command = [[
&bold-blue-light;[       Discord ANSI Formatter       ]&clear-reset;&white;
 For all your discord colored needs.

&yellow-highlight;[               Help                 ]&clear-reset;&white;
ds_af help - &blue-clear-bold;Shows this help panel&clear-reset-white;
ds_af file &green;<file_path>&white; - &blue-clear-bold;Converts a file into .dsansi&clear-reset-white;
ds_af preview &green;<text>&white; - &blue-clear-bold;Converts a file and prints back a preview&clear-reset-white;
ds_af text &green;<text>&white; - &blue-clear-bold;Converts text and prints back a preview&clear-reset-white;

&yellow-highlight;[              Credit                ]&clear-reset;&white;
  Created by guhw with lua using luvi
]]

messages.no_file = "&red;File does not exist.&white;"

return messages