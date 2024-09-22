import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RadioPlayerComponent } from './radio-player.component';

describe('RadioPlayerComponent', () => {
  let component: RadioPlayerComponent;
  let fixture: ComponentFixture<RadioPlayerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RadioPlayerComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(RadioPlayerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
