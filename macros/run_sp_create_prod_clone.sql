{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call berchain._internal.create_prod_clone(
        'berchain',
        'berchain_dev',
        'internal_dev'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}
