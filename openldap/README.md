[Install LDAP Server in Centos Step by Step](https://www.unixmen.com/install-ldap-server-in-centos-step-by-step/)

[Install and Configure OpenLDAP Server on CentOS 8](https://computingforgeeks.com/install-configure-openldap-server-centos/)

[Step by Step OpenLDAP Server Configuration on CentOS 7 / RHEL 7](https://www.itzgeek.com/how-tos/linux/centos-how-tos/step-step-openldap-server-configuration-centos-7-rhel-7.html)

[How to Install LDAP on CentOS 7](https://linuxhostsupport.com/blog/how-to-install-ldap-on-centos-7/)

[安全注意事项](https://www.openldap.org/doc/admin24/security.html)

[HOWTO Install and Configure OpenLDAP for federated access on CentOS](https://github.com/ConsortiumGARR/idem-tutorials/blob/master/idem-fedops/miscellaneous/HOWTO%20Install%20and%20Configure%20OpenLDAP%20for%20federated%20access-CentOS.md)

[启用安全组,关联属性memberOf](https://kifarunix.com/how-to-create-openldap-member-groups/)

[Enable memberOf attribute on an openldap server.](https://gist.github.com/dnozay/511968813c070b07bc85)


[动态组递归用户](https://github.com/go-gitea/gitea/issues/16583)
[使用 groupOfURLs objectClass](https://github.com/osixia/docker-openldap/issues/355)
[openldap 配置](https://gitlab.ow2.org/ldaptoolbox/openldap-initscript/-/blob/master/config-template.conf)
[LDAP组的概念以及命令](https://blog.csdn.net/woshaguayi/article/details/116011638)

异常处理:

[Why does this ldapadd command quit with an "Invalid syntax" error?](https://serverfault.com/questions/531495/why-does-this-ldapadd-command-quit-with-an-invalid-syntax-error)

[How To Change Account Passwords on an OpenLDAP Server](https://www.digitalocean.com/community/tutorials/how-to-change-account-passwords-on-an-openldap-server)


rootDN: cn=ldapadm,dc=fly-develop,dc=com
pwd: ldap@admin

自动生成的其他用户密码全部为`123456`

### php代码生成ldap密码

#### SSHA
```php 
<?php
function ldap_ssha($password) {
    //生成一随机字符串
    $salt = md5(uniqid(time()));

    return "{SSHA}" . base64_encode(pack('H*', sha1($password . $salt)) . $salt);
}
```

#### MD5
```php
'{MD5}' . base64_encode(md5($password, true))
```
或者
```php
'{MD5}' . base64_encode(pack('H*', md5($password)))
```

#### SHA
```php
'{SHA}' . base64_encode(pack('H*', sha1($password))) 
```
