import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CommonModule } from '@angular/common';

import { SandboxAudioPlayerComponent } from './sandbox-audio-player.component';

describe('SandboxAudioPlayerComponent', () => {
  let component: SandboxAudioPlayerComponent;
  let fixture: ComponentFixture<SandboxAudioPlayerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SandboxAudioPlayerComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(SandboxAudioPlayerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
