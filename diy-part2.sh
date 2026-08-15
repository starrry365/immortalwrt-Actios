#!/bin/bash
# DIY脚本
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part2.sh
# 功能说明: OpenWrt DIY脚本第2部分（更新feeds之后）
# 版权: (c) 2019-2024 P3TERX <https://p3terx.com>
# 基于 MIT 开源协议，详见 /LICENSE

# 修改默认IP地址为 192.168.10.1（管理地址）
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate


# 修改默认主题为 argon（路径不存在时跳过，不中断编译）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# 系统默认语言：简体中文（LuCI 界面强制 zh-cn，不依赖浏览器语言）
# 覆写 luci-base 的默认配置，保证固件"开箱即中文"
# （mediaurlbase 由 argon 主题的 uci-defaults 自动设置为 /luci-static/argon，无需在此处理）
LUCI_DEFAULT_CONFIG="feeds/luci/modules/luci-base/root/etc/config/luci"
if [ -f "$LUCI_DEFAULT_CONFIG" ]; then
  sed -i "s/option lang 'auto'/option lang 'zh-cn'/" "$LUCI_DEFAULT_CONFIG"
  echo "✅ LuCI 默认语言已设为 简体中文(zh-cn)"
else
  echo "⚠️ 未找到 $LUCI_DEFAULT_CONFIG（feeds 版本可能不同），跳过默认语言设置"
fi

# 升级 luci-theme-argon 到 jerrykuku 官方正式版 v2.4.6（支持暗色模式/动态壁纸/多语言）
# 锁定 tag 避免拉到 master 上尚未发布为正式版本的旧 PKG_VERSION（如 2.4.3）
# 删除官方 feed 的旧版主题，替换为 GitHub 正式版，避免包名冲突
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth 1 -b v2.4.6 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# 添加 argon 主题配置面板（网页端自定义主题颜色/暗色模式/壁纸等）
# 官方 luci feed 不含此应用，clone 到 package/ 不会冲突；锁定正式版 v0.9
git clone --depth 1 -b v0.9 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
