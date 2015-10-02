#!/usr/bin/env bash

package=${1%/}
package_name=${package##*/}
package_name=${package_name%.vmwarevm}
dst=${2%/}

#echo $package
#echo $package_name

/Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool --acceptAllEulas "$package/$package_name.vmx" "$dst/${package_name}.t.ova"

