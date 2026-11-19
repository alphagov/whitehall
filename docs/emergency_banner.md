# Emergency Banner

The emergency banner is controlled by Whitehall, and consumed by Frontend apps. At time of writing, we are switching over from a redis-based system to a configmap-based system.

## Redis

Whitehall manages the key `emergency_banner` in its redis cache. When the banner is set, it writes the banner values to this cache. Frontend apps that need to deploy the banner use [govuk_web_banner](https://www.github.com/alphagov/govuk_web_banner) read from this cache every 5 minutes and display the banner if the banner campaign type and heading (at minimum) are set. This requires all relevant apps to have read access to Whitehall's redis cache.

## Kubernetes ConfigMap

At the same time it writes values to the redis key, Whitehall also writes to the `govuk-apps-emergency-banner` configMap. The configMap is mounted on relevant frontend apps as `/etc/emergency-banner/config.yaml`. A process in the kubernetes cluster picks up changes to this configMap and automatically restarts the relevant apps. This means they only have to read the value once, at boot time.

### govuk-preview-app

Note that this also works in govuk-preview-app, but the process to watch the configMap and restart the pods is not present there, so the frontend pods will need to be manually rollout-restarted to deploy the banner.

## Future

Once all frontend apps are moved to the ConfigMap version of [govuk_web_banner], the redis part of the system will be removed, and the configMap will become the source of truth.


[govuk_web_banner]: https://www.github.com/alphagov/govuk_web_banner