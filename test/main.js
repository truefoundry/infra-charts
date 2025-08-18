import { load } from 'js-yaml';

function parseYamlString(yamlString) {
  try {
    return load(yamlString);
  } catch (e) {
    console.log("Error parsing YAML string:", e);
    return null;
  }
}

const mountDetails = parseYamlString(   `
    - mountPath: /var/run/secrets/test-secret
      secretName: test-secret
      subPath: my-subPath
      type: secret`);

console.log(mountDetails);