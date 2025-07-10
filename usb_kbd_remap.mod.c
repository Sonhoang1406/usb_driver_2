#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/export-internal.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_MITIGATION_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif



static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x1fe379e5, "hid_hw_stop" },
	{ 0x651abe8c, "hid_open_report" },
	{ 0xbffac707, "hid_hw_start" },
	{ 0xb06c04b, "_dev_err" },
	{ 0xafdc552, "hid_unregister_driver" },
	{ 0xdaf5e468, "input_event" },
	{ 0x796df453, "param_ops_uint" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x92997ed8, "_printk" },
	{ 0x4abb3f38, "__hid_register_driver" },
	{ 0xb1d6f3f2, "module_layout" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("hid:b0003g*v00000461p00004E8E");

MODULE_INFO(srcversion, "80768F684131727301E3EBC");
MODULE_INFO(rhelversion, "9.7");
