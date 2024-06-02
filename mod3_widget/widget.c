#include <linux/errno.h>
#include <linux/kobject.h>
#include <linux/module.h>
#include <linux/miscdevice.h>

#define WIDGET_DEV_NAME "widget_dev"
#define WIDGET_KSET_NAME "diagnostics"
#define WIDGET_PARAM_PAYLOAD_SZ 16

struct widget_data {
	u32 serial_number;
	// Maybe would be idiomatic to declare base as first member
	struct kset base;
};
#define kobj_to_kset(kobj_of_kset) container_of(kobj_of_kset, struct kset, kobj);
#define kset_to_widget_data(kset) container_of(kset, struct widget_data, base);

enum diagn_param_type {
	DIAGN_PARAM_TYPE_STR = 11
};

struct diagn_param {
	struct kobject base;
	char payload[WIDGET_PARAM_PAYLOAD_SZ];
};
#define kobj_to_diagn_param(kobj) container_of(kobj, struct diagn_param, base);

static void show_kobject_info(struct kobject *kobj)
{
	const char *path;

	path = kobject_get_path(kobj, GFP_KERNEL);
	pr_err("\twidget: current-kobj path: %s\n", path);
	kfree(path);

	if (kobj->parent) {
		path =  kobject_get_path(kobj->parent, GFP_KERNEL);
		pr_err("\twidget: parent-kobj path: %s\n", path);
		kfree(path);
	} else {
		pr_err("\twidget: parent-kobj is NULL\n");
	}

	if (!kobj->kset) {
		pr_err("\twidget: current-kobj-kset in NULL\n");
	} else {
		path =  kobject_get_path(&kobj->kset->kobj, GFP_KERNEL);
		pr_err("\twidget: current-kobj-kset path: %s\n", path);
		kfree(path);
	}
}

// ---------------------------------------------------------------------------
// Generic _show and _store for all kobjects of diagn_param_ktype
static ssize_t diagn_attr_show(struct kobject *kobj, struct attribute *attr, char *buf)
{
	pr_err("\n\twidget: COMMON: %s\n", __FUNCTION__);
	pr_err("\twidget: ATTR: %s\n", attr->name);
	show_kobject_info(kobj);

	struct kobj_attribute *kattr = container_of(attr, struct kobj_attribute, attr);
	ssize_t ret = -EIO;
	if (kattr->show)
		ret = kattr->show(kobj, kattr, buf);
	return ret;
}

static ssize_t diagn_attr_store(struct kobject *kobj, struct attribute *attr, const char *buf, size_t count)
{
	pr_err("\n\twidget: COMMON %s:\n", __FUNCTION__);
	pr_err("\twidget: ATTR: %s\n", attr->name);
	show_kobject_info(kobj);

	struct kobj_attribute *kattr = container_of(attr, struct kobj_attribute, attr);
	ssize_t ret = -EIO;
	if (kattr->store)
		ret = kattr->store(kobj, kattr, buf, count);
	return ret;
}

static const struct sysfs_ops diagn_sysfs_ops = {
	.show = diagn_attr_show,
	.store = diagn_attr_store,
};
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// This is specific for id_attr
static ssize_t id_attr_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
	pr_err("\t--> widget: %s:\n", __FUNCTION__);
	struct diagn_param *diagn_id = kobj_to_diagn_param(kobj);
	return sysfs_emit(buf, "%s\n", diagn_id->payload);
}

static ssize_t id_attr_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
	pr_err("\t--> widget: %s:\n", __FUNCTION__);
	if (count > WIDGET_PARAM_PAYLOAD_SZ)
		return -EIO;
	
	struct diagn_param *diagn_id = kobj_to_diagn_param(kobj);
	strncpy(diagn_id->payload, buf, count);
	memset(diagn_id->payload + count, 0, WIDGET_PARAM_PAYLOAD_SZ - count);

	return count;
}

static struct kobj_attribute id_attr = __ATTR(id, 0644, id_attr_show, id_attr_store);

static struct attribute *diagn_attrs[] = {
	&id_attr.attr,
	NULL
};
// This creates diagn_groups list with one entry &diagn_group with &diagn_attrs in it
ATTRIBUTE_GROUPS(diagn);
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
static void diagn_param_release(struct kobject *kobj)
{
	pr_err("\n\t---- widget: diagn_param RELEASE:\n");
	show_kobject_info(kobj);

	struct diagn_param *param = kobj_to_diagn_param(kobj);
	kfree(param);
}
// ---------------------------------------------------------------------------

static const struct kobj_type diagn_param_ktype = {
	.sysfs_ops = &diagn_sysfs_ops,
	.default_groups = diagn_groups,
	.release = diagn_param_release,
};

static const struct file_operations widget_chrdev_ops = {
	.owner		= THIS_MODULE
	// .mmap = ...
	// .unlocked_ioctl = ...
	// .compat_ioctl = ...
	// ...
};

static struct miscdevice widget_miscdev = {
	.minor		= MISC_DYNAMIC_MINOR,
	.name		= WIDGET_DEV_NAME,
	.fops		= &widget_chrdev_ops
};

static void __maybe_unused diagnostics_params_destroy(struct kset *parent_kset, const char *param_name)
{
	struct kobject *kobj = kset_find_obj(parent_kset, param_name);


	pr_err("\n--- kobj detached from sysfs and being put:\n");
	show_kobject_info(kobj);

	kobject_del(kobj);
	kobject_put(kobj);

	const struct kobj_type *ktype = get_ktype(kobj);
	if (ktype && ktype->release)
		ktype->release(kobj);
}

static int __maybe_unused diagnostics_params_create(struct kset *parent_kset, enum diagn_param_type param_type, const char *param_name)
{
	const char default_diagn_param_str[] = "empty";

	struct diagn_param *param;
	param = kzalloc(sizeof(*param), GFP_KERNEL);
	if (!param) {
		pr_err("\twidget: [-] param alloc\n");
		return -ENOMEM;
	}

	if (param_type == DIAGN_PARAM_TYPE_STR) {
		strncpy(param->payload, default_diagn_param_str, strlen(default_diagn_param_str));
	} else {
		pr_err("widget: [!] unknown param type");
	}
	param->base.kset = parent_kset;

	// diagn_param_ktype is common for multiple attrs
	int ret = kobject_init_and_add(&param->base, &diagn_param_ktype, NULL, param_name);
	if (ret) {
		pr_err("\twidget: [-] param kobject_init_and_add\n");
		kobject_put(&param->base);
		kfree(param);
		return ret;
	}
	kobject_uevent(&param->base, KOBJ_ADD);

	pr_err("\n+++ diagn_param->base:\n");
	show_kobject_info(&param->base);

	return ret;
}

static struct widget_data *widget_data;

static void widget_data_kset_release(struct kobject *kobj)
{
	pr_err("\n\t--- widget: kset RELEASE:\n");
	show_kobject_info(kobj);

	struct kset *mid_ptr = kobj_to_kset(kobj);
	struct widget_data *data = kset_to_widget_data(mid_ptr);
	kfree(data);
	widget_data = NULL;
}

static const struct kobj_type widget_data_kset_ktype = {
	.sysfs_ops	= &kobj_sysfs_ops,
	.release	= widget_data_kset_release,
};

static struct widget_data *widget_data_kset_create(const char *name, struct kobject *parent_kobj)
{
	struct widget_data *data;
	int ret;

	data = kzalloc(sizeof(*data), GFP_KERNEL);
	if (!data) {
		pr_err("\twidget: [-] widget_data alloc\n");
		return NULL;
	}
	ret = kobject_set_name(&data->base.kobj, "%s", name);
	if (ret) {
		pr_err("\twidget: [-] kobject_set_name('%s')\n", name);
		kfree(data);
		return NULL;
	}
	data->base.uevent_ops = NULL;
	data->base.kobj.parent = parent_kobj;
	data->base.kobj.ktype = &widget_data_kset_ktype;
	data->base.kobj.kset = NULL;
	data->serial_number = 12345678;

	pr_err("\n+++ widget_data->kset.kobj:\n");
	show_kobject_info(&data->base.kobj);

	return data;
}

static int create_diagnostics_kset(struct kobject *parent_kobj)
{
	struct widget_data *data = widget_data_kset_create(WIDGET_KSET_NAME, parent_kobj);
	if (!data) {
		pr_err("\twidget: [-] widget_data_kset_create\n");
		return -ENOMEM;
	}

	int err;
	err = kset_register(&data->base);
	if (err) {
		pr_err("\twidget: [-] kset_register\n");
		kfree(data);
		return err;
	}

	diagnostics_params_create(&data->base, DIAGN_PARAM_TYPE_STR, "parameters");

	widget_data = data;

	return 0;
}

static void destroy_diagnostics_kset(void)
{
	struct widget_data *data = widget_data;

	diagnostics_params_destroy(&data->base, "parameters");
	kset_unregister(&data->base);
}

static int __init widget_init(void)
{
	pr_err("widget: init\n");
	int ret;

	ret = misc_register(&widget_miscdev);
	if (ret) {
		pr_err("widget: [-] registration\n");
		goto out;
	}
	pr_err("widget: [!] Underlying device::driver_data is %s\n",
	       (dev_get_drvdata(widget_miscdev.this_device) ? "NOT NULL" : "NULL"));

	pr_err("\n+++ widget_miscdev.this_device->kobj:\n");
    show_kobject_info(&widget_miscdev.this_device->kobj);

	ret = create_diagnostics_kset(&widget_miscdev.this_device->kobj);
	if (ret) {
		pr_err("widget: [-] create_diagnostics_kset\n");
		goto err_diagnostic_kset;
	}

	ret = 0;

out:
	return ret;

err_diagnostic_kset:
	misc_deregister(&widget_miscdev);
	goto out;
}

static void __exit widget_exit(void)
{
	pr_err("widget: exit\n");
	destroy_diagnostics_kset();
	misc_deregister(&widget_miscdev);
}

module_init(widget_init);
module_exit(widget_exit);

MODULE_AUTHOR("Maciej Bielski");
MODULE_DESCRIPTION("Widget driver");
MODULE_LICENSE("GPL");

