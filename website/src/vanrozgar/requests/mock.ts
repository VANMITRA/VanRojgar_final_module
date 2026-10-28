/* Mock requests. TODO: replace with API calls. */
export type Status='pending'|'countered'|'accepted'|'rejected'|'cancelled';
export type Req={id:string,p:string,v:string,qty:number,st:Status,d:string,why:string,how:string,need:string,msg?:string,co?:{qty:number,msg:string}};

export const STATUS_LABEL:Record<Status,string>={pending:'Pending',countered:'Counter offer',accepted:'Accepted',rejected:'Rejected',cancelled:'Cancelled'};

export const MOCK_REQUESTS:Req[]=[
  {id:'VR-0005',p:'bamboo',v:'Pahine',qty:50,st:'pending',d:'27 Oct 2026',why:'Craft or construction',how:'Pick up',need:'2026-11-10'},
  {id:'VR-0004',p:'bamboo',v:'Take Harsh',qty:200,st:'accepted',d:'24 Oct 2026',why:'Resale in my shop',how:'Deliver to me',need:'2026-11-05',msg:'Accepted. The poles will be ready from Monday.'},
  {id:'VR-0003',p:'awla',v:'Met Chandrachi',qty:100,st:'countered',d:'22 Oct 2026',why:'Processing or making products',how:'Pick up',need:'2026-11-02',co:{qty:60,msg:'We can give 60 kg now. The rest will be ready in two weeks.'}},
  {id:'VR-0002',p:'tamarind',v:'Dongargaon',qty:200,st:'rejected',d:'20 Oct 2026',why:'Resale in my shop',how:'Deliver to me',need:'2026-10-30',msg:"This season's tamarind is already promised to another buyer. Please try again after the next harvest."},
  {id:'VR-0001',p:'moh',v:'Ambaee',qty:50,st:'cancelled',d:'18 Oct 2026',why:'My own use',how:'Pick up',need:'2026-11-05'},
];
