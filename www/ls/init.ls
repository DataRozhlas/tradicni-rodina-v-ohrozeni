window.ig =
  projectName : "tradicni-rodina-v-ohrozeni"
  containers: {}

_gaq?.push(['_trackEvent', 'ig', ig.projectName]);
containers = document.querySelectorAll '.ig'
if not containers.length
  document.body.className += ' ig'
  window.ig.containers.base = document.body
else
  for container in containers
    window.ig.containers[container.getAttribute 'data-ig'] = container

if d3?
  if document.getElementById 'fallback'
    that.parentNode.removeChild that
