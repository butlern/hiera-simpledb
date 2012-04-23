What?
=====

An Amazon AWS SimpleDB backend for Hiera

Configuration?
==============

A sample Hiera config file that activates this backend can be seen below:

<pre>
---
:backends: simpledb
:hierarchy: %{location}
            sdb-puppet
:simpledb:
   :access_key_id: AAAAAAAAAAAAAAAAAAAAAAAAA
   :secret_access_key: BBBBBBBBBBBBBBBBBBBBBBBBB
   :key: "%{key}"
</pre>

Contact?
=========

Nathan Butler / nathan.butler@gmail.com
