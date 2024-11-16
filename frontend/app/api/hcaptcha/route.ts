import { NextResponse } from 'next/server';
import axios from 'axios';

export async function POST(request: Request) {
  try {
    const { token } = await request.json();
    const secret = process.env.HCAPTCHA_SECRET_KEY || 'default_secret_key';

    // Create form data
    const data = new URLSearchParams();
    data.append('secret', secret);
    data.append('response', token);

    // Send POST request with form data in the body
    const response = await axios.post('https://hcaptcha.com/siteverify', data, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });

    if (response.data.success) {
      return NextResponse.json({ success: true });
    } else {
      return NextResponse.json({ success: false }, { status: 400 });
    }

  } catch (error) {
    console.error('Error verifying hCaptcha token:', error);
    return NextResponse.json({ success: false }, { status: 500 });
  }
}
