Create Manually Installed Astara Fuel 8.0 Plugin on Ubuntu Trusty 14.04
=======================================================================

``https://wiki.openstack.org/wiki/Fuel/Plugins#Preparing_an_environment_for_plugin_development``

    sudo apt-get install createrepo rpm dpkg-dev
    easy_install pip
    pip install fuel-plugin-builder
    git clone https://github.com/stackforge/fuel-plugins.git
    cd fuel-plugins/fuel_plugin_builder/
    sudo python setup.py develop

``https://wiki.openstack.org/wiki/Fuel/Plugins#Using_Fuel_Plugin_Builder_tool``

    fpb --create fuel-plugin-astara
    fpb --build fuel-plugin-astara
    

Debug UI
--------

blah blah

Debug Deployment
----------------

blah blah
