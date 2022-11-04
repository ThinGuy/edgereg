import axios, {AxiosInstance} from 'axios';
import {Writable} from 'stream';
import fs from 'fs';
import HttpsProxyAgent from 'https-proxy-agent'

// abstract class HttpClient {
//   protected readonly instance: AxiosInstance;

//   public constructor(baseURL: string) {
//     this.instance = axios.create({
//       baseURL,
//     });

//     this._initializeResponseInterceptor();
//   }

//   private _initializeResponseInterceptor = () => {
//     this.instance.interceptors.response.use(
//       this._handleResponse,
//       this._handleError,
//     );
//   };

//   private _handleResponse = ({ data }: AxiosResponse) => data;

//   protected _handleError = (error: any) => Promise.reject(error);
// }

export default class Client {
  // private authToken: string
  private client?: AxiosInstance
  private tokenExpiry: number = 0

  constructor(
    readonly host: string,
    readonly username: string,
    readonly password: string
  ) {}

  private async getProjects() {
    return ["hello"];
  }

  private async getAuthToken(httpsProxyAgent: any) {
    const url = `https://${this.host}/v1/auth/authenticate`;
    return axios.post(url, {
      emailId: this.username,
      password: this.password,
    }, {timeout: 5000, httpsAgent: httpsProxyAgent, proxy: false})
      .then(response => response.data)
      .catch(e => {
        console.log('error: ', e?.response?.data);
        // console.log('error: ', JSON.stringify(e, null, 2));
        throw e;
      });
  }


  private async getClient() {
    // TODO expired
    if (this.client && Date.now() < this.tokenExpiry) {
      return this.client;
    }

    let proxyAgent;
    const httpsProxy = process.env.HTTPS_PROXY
    console.log("Logging in", "proxy: ", httpsProxy);
    if (httpsProxy) {
      // https://github.com/axios/axios/issues/3459
      proxyAgent = new (HttpsProxyAgent as any)(httpsProxy);
    }

    const authToken = await this.getAuthToken(proxyAgent);

    this.client = axios.create({
      baseURL: `https://${this.host}`,
      timeout: 50000,
      httpsAgent: proxyAgent,
      proxy: false,
      headers: {
        'Authorization' : authToken['Authorization'],
      }
    });

    this.tokenExpiry = Date.now() + 10*60*1000;

    return this.client;

  }
  async getProjectUID(projectName: string) {
    const c = await this.getClient();
    return c.get(`/v1/projects?filters=metadata.name=${projectName}`)
      .then( response => response.data )
      .then(data => {
        if (!data || !data.items?.length) {
          throw new Error(`No project found with name '${projectName}'`);
        }

        return data.items[0].metadata.uid;
      });
  }


  async getEdgeAppliance(projectUID: string, edgeHostUID: string) {
    const c = await this.getClient();
    return c.get(`/v1/edgehosts/${edgeHostUID}/?ProjectUid=${projectUID}`)
      .then( response => response.data );
  }

  

  async createEdgeAppliance(projectUID: string, data: any) {
    const c = await this.getClient();

    return c.post(`/v1/edgehosts?ProjectUid=${projectUID}`, data)
      .then( response => {
        return response.data.uid;
      });
  }

}
