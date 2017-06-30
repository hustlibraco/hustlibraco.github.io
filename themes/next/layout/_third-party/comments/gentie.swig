
  {% if theme.gentie_productKey %}
    {% set gentie_productKey = theme.gentie_productKey %}
    <script>
      var cloudTieConfig = {
        url: document.location.href, 
        sourceId: "",
        productKey: "{{gentie_productKey}}",
        target: "cloud-tie-wrapper"
      };
    </script>
    <script src="https://img1.cache.netease.com/f2e/tie/yun/sdk/loader.js"></script>
  {% endif %}

