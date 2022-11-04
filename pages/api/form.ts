import Client from './client'

interface Credentials {
  host: string;
  username: string;
  password: string;
}


export async function doesEdgeApplianceExist(c: Client, projectUid: string, edgeUid: string) {
  try {
    await c.getEdgeAppliance(projectUid, edgeUid);
    return true;
  } catch (e) {
    return false;
  }
}

export default async function handler(req, res) {
  const body = req.body
  console.log('body: ', body)
  const appliance = body.appliance;
  const [clusterName,crmProject] = body.store.split(";");

  const scApi = process.env.SC_API
  const scUser = process.env.SC_USER
  const scPassword = process.env.SC_PASSWORD
  const scProjectName = process.env.SC_PROJECT_NAME || "Default"

  console.log("New request: ", appliance, crmProject)

  if (!appliance || !clusterName || !crmProject) {
    return res.json({ data: 'appliance or crmProject name not found' })
  }

  const c = new Client(scApi, scUser, scPassword);
  // const kubeconfig = await getKubeconfigFromSpectroCloud(c, scProjectName, "vmware-prod-2");
  const projectUid = await c.getProjectUID(scProjectName);
  const alreadyExists = await doesEdgeApplianceExist(c, projectUid, appliance);
  if (alreadyExists) {
    console.log("It already exists! - ");
    return res.redirect(303, '/already')
  }

  console.log("Creating new edge appliance");
  const data = {
    metadata: {
      name: appliance,
      uid: appliance,
      // labels: {
      //   cluster: clusterUid,
      //   name: clusterName,
      // }
    },
  }

  const applianceUid = await c.createEdgeAppliance(projectUid, data);
  console.log("Appliance UID:", applianceUid);

  res.redirect(303, '/registered')

}
