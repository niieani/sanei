# Example Operation
# =================
# .. module:: example.operation
#    :synopsis: An example operation.
#    :platform: raring
# .. moduleauthor:: Bazyli Brzoska <bazyli.brzoska@gmail.com>
#
# Module
# ++++++
#
# :Description: This is an example of a long description.
#       It can span over multiple lines.
#       And we can use **coloring** *like* that.
#       
#       More info on possibilities:
#       http://sphinx-doc.org/domains.html
#
# :Dependencies: - sanei
#                - apt:bash
# :Provides: - apt:mc
#
# Arguments
# +++++++++
#
# .. cmdoption:: test
#
#    The first parameter.
#
# Variables
# +++++++++
#
# .. envvar:: HOSTNAME
#
#    Your hostname.
#
#    :default: test
#
# .. envvar:: IP
#
#    :default: test
#
#    Your IP.
#
# .. envvar:: NONDEFAULT
#
#    Your IP.
# 
# Code
# ++++
#
# .. function:: example_function(text[, unused=None])
#
#    Echos "example function $text".
#
#    :param text: text to be displayed
#    :type unused: boolean or None
#    :returns: int -- the return code.
#
function example_function(){
	local text="$1"
	info "example function $text"
	info "your hostname: $HOSTNAME"
}