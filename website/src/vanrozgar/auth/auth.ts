/* Auth stubs. Phone number with OTP only, no password. */

/* TODO: call the real SMS service to send the OTP. */
export async function sendOtp(phone:string):Promise<boolean>{
  await new Promise(r=>setTimeout(r,400));
  return /^[6-9][0-9]{9}$/.test(phone);
}

/* TODO: check the code with the real SMS service.
   DEV ONLY: the code 123456 is accepted for every phone number. Remove before launch. */
const DEV_OTP='123456';
export async function verifyOtp(phone:string,code:string):Promise<boolean>{
  await new Promise(r=>setTimeout(r,400));
  return /^[6-9][0-9]{9}$/.test(phone)&&code===DEV_OTP;
}

/* TODO: ask the server which role this phone number has. Until then a login gives the buyer role. */
export async function roleForPhone(_phone:string):Promise<string>{return 'buy'}

/* TODO: post the form (and files) to the server. */
export async function submitForm(_kind:string,_data:unknown):Promise<boolean>{
  await new Promise(r=>setTimeout(r,600));
  return true;
}
