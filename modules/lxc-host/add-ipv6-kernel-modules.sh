modprobe ip6_tables
modprobe ip6table_filter
modprobe ip6table_mangle
modprobe ip6t_REJECT

if [[ $(cat /etc/modules | grep ip6_tables | wc -l) -eq 0 ]]; then
    echo ip6_tables >> /etc/modules
fi

if [[ $(cat /etc/modules | grep ip6table_filter | wc -l) -eq 0 ]]; then
    echo ip6table_filter >> /etc/modules
fi

if [[ $(cat /etc/modules | grep ip6table_mangle | wc -l) -eq 0 ]]; then
    echo ip6table_mangle >> /etc/modules
fi

if [[ $(cat /etc/modules | grep ip6t_REJECT | wc -l) -eq 0 ]]; then
    echo ip6t_REJECT >> /etc/modules
fi
