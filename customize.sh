SKIPUNZIP=1

status=""
architecture="armv8"
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/clash"
modules_dir="/data/adb/modules"
ca_path="/system/etc/security/cacerts"
mod_config="${clash_data_dir}/clash.config"

mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}
mkdir -p ${MODPATH}${ca_path}

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2

if [ "$(md5sum ${MODPATH}/data/clash.config | awk '{print $1}')" != "$(md5sum ${mod_config} | awk '{print $1}')" ] ; then
    if [ -f "${mod_config}" ] ; then
        mv -f ${mod_config} ${clash_data_dir}/config.backup
        ui_print "- 配置文件有变化,原配置文件已备份为config.backup"
        ui_print "- 建议查看配置文件无误后再重启手机"
    fi
    mv ${MODPATH}/data/clash.config ${clash_data_dir}/
else
    rm -rf ${MODPATH}/data/clash.config
fi

if [ ! -f "${clash_data_dir}/template" ] ; then
    mv ${MODPATH}/data/template ${clash_data_dir}/
else
    rm -rf ${MODPATH}/data/template
fi

tar -xjf ${MODPATH}/binary/${ARCH}.tar.bz2 -C ${MODPATH}/system/bin/
mv ${MODPATH}/data/cacert.pem ${MODPATH}${ca_path}
mv ${MODPATH}/yacd ${clash_data_dir}/
rm -rf ${MODPATH}/binary

if [ ! -f "${clash_data_dir}/packages.list" ] ; then
    mv ${MODPATH}/data/packages.list ${clash_data_dir}/
else
    rm -rf ${MODPATH}/data/packages.list
fi

if [ ! -f "${clash_data_dir}/Country.mmdb" ] ; then
    mv ${MODPATH}/data/Country.mmdb ${clash_data_dir}/
else
    rm -rf ${MODPATH}/data/Country.mmdb
fi

rm -rf ${MODPATH}/data

sleep 1

ui_print "- 开始设置环境权限."
set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
set_perm  ${MODPATH}${ca_path}/cacert.pem 0 0 0644
set_perm  ${MODPATH}/system/bin/curl 0 0 0755
set_perm_recursive ${MODPATH}/scripts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
set_perm  ${MODPATH}/system/bin/clash  ${system_uid}  ${system_gid}  6755
set_perm  ${clash_data_dir}/clash.config ${system_uid} ${system_gid} 0755
set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644
set_perm  ${clash_data_dir}/Country.mmdb ${system_uid} ${system_gid} 0644