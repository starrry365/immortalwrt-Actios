#!/bin/bash
# DIY脚本
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part1.sh
# 功能说明: OpenWrt DIY脚本第1部分（更新feeds之前）
# 版权: (c) 2019-2024 P3TERX <https://p3terx.com>
# 基于 MIT 开源协议，详见 /LICENSE

# 取消注释一个源
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 添加第三方 feed 源（small-package 包含 openclash/passwall/ssr-plus 等常用插件）
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
# 添加第三方源，iStore 应用商店，编译时包名输入 luci-app-store
echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default


# OpenClash代理
# git clone --depth 1 https://github.com/vernesong/OpenClash.git OpenClash

# turboacc网络加速（需要用户在页面选择 luci-app-turboacc 后，由编译脚本自动执行，此处不再无条件运行）
# curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 调试
# sed -i 's|src-git-full openstick https://github.com/lkiuyu/openstick-feeds.git|src-git-full openstick https://github.com/xuxin1955/openstick-feeds|g' feeds.conf.default


# ============================================================================
# MF32 SIM 供电修复（固化到固件，避免每次重刷 boot 都丢 SIM）
# ----------------------------------------------------------------------------
# 根因：上游 msm8916-ufi-mf32.dts 把 SIM 使能脚 sim-en(gpio24) 配成 output-low，
#       等于切断 SIM 卡供电，插卡不识别。必须改成 output-high 才能供电。
# 此前只能刷机后手动 patch boot 分区 DTB，重刷 boot 即失效；此处从源头固化，
# 编译出的 boot.img 自带修复，重刷不再丢 SIM。
# 注意：只改 sim-en-pins 块内 gpio24 的 output-low → output-high，
#       其余 esim-sel-pins(gpio50/51) / sim-sel-pins(gpio49) 保持原样（选卡逻辑）。
# ============================================================================
MF32_DTS=$(find target/linux/msm89xx -name 'msm8916-ufi-mf32.dts' 2>/dev/null | head -1)
if [ -n "$MF32_DTS" ]; then
  # 仅在 sim-en-pins 作用域内把 output-low 改成 output-high，避免误改 esim-sel-pins
  sed -i '/sim-en-pins {/,/};/ s/output-low/output-high/' "$MF32_DTS"
  # 校验：sim-en-pins 块内必须出现 output-high
  if sed -n '/sim-en-pins {/,/};/p' "$MF32_DTS" | grep -q 'output-high'; then
    echo "✅ MF32 SIM gpio24 已固化为 output-high（文件: $MF32_DTS）"
  else
    echo "⚠️ MF32 SIM gpio24 修复未生效，可能上游 DTS 已变更 sim-en-pins 结构，请人工确认"
  fi
else
  echo "⚠️ 未找到 target/linux/msm89xx/ 下的 msm8916-ufi-mf32.dts，跳过 SIM 修复（不影响编译）"
fi



